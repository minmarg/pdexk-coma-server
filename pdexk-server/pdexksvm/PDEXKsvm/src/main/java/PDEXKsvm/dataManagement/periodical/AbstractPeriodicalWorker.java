package PDEXKsvm.dataManagement.periodical;

import java.util.Date;
import java.util.Map;
import java.util.Set;
import java.util.TimerTask;
import java.util.List;

import org.apache.log4j.Logger;

import PDEXKsvm.cache.Cache;
import PDEXKsvm.dataManagement.JobStatus;
import PDEXKsvm.dataManagement.SMTPMailService;
import PDEXKsvm.dataManagement.transfer.IDataManager;
import PDEXKsvm.dataManagement.transfer.LocalPBSDataManager;
import PDEXKsvm.dataManagement.transfer.PublicKeyAuthentication;
import PDEXKsvm.dataManagement.transfer.RemotePBSDataManager;
import PDEXKsvm.entities.DataFile;
import PDEXKsvm.entities.EmailNotification;
import PDEXKsvm.entities.Job;
import PDEXKsvm.entities.JobParams;
import PDEXKsvm.entities.Workstation;
import PDEXKsvm.exceptions.JobFailureException;
import PDEXKsvm.services.IDataSource;

public abstract class AbstractPeriodicalWorker extends TimerTask
{
	private static final Logger periodicalWorkerLog = Logger.getLogger("periodicalWorker");
	
	private boolean run = true;
	
	private long sleep = 10;

	private IDataSource  dataSource  = null;
	private IDataManager dataManager = null;

	public AbstractPeriodicalWorker(IDataSource dataSource)
	{
		this.dataSource 	= dataSource;
	}

	public void run()
	{
		while(run)
		{
			try
			{
				//Status not equals FINISHED nor ERRORS nor CANCELED
				List<Job> notFinishedJobs = dataSource.getNotFinishedJobs();

				if(notFinishedJobs != null && notFinishedJobs.size() > 0)
				{
					Workstation workstation = Cache.getWorkstation();
					EmailNotification emailNotification = Cache.getEmailNotificationParams();
				
					if(workstation.isLocal())
					{
						dataManager = new LocalPBSDataManager();
					}
					else
					{
						dataManager = new RemotePBSDataManager(PublicKeyAuthentication.connect(workstation.getUsername(), 
								workstation.getHostname(), workstation.getKeyFilePath(), workstation.getKeyfilePass()));
					}
												
					//submits jobs to the workstation
					//if everything is fine sets job status to QUEUED
					
					for(Job job: notFinishedJobs)
					{
						if(job.getStatus().equals(JobStatus.SUBMITTED.getStatus()))
						{
							try
							{
								periodicalWorkerLog.error("Submitting: " + job.getGeneratedId());
								//Before executing query for PBS tests if update is available (maybe DB is shut down)
								dataSource.update(job);
								//Submits job
								String workstationId = jobSubmission(dataManager, workstation.isLocal(), 
																	 workstation.getGlobalFilePath(), 
																	 workstation.getRemoteFilePath(), 
																	 job.getGeneratedId(), 
																	 job.getDataFiles(), job.getType());
								//Sets workstation ID and status to QUEUED
								if(workstationId != null)
								{
									job.setWorkstationId(workstationId);
									job.setStatus(JobStatus.QUEUED.getStatus());
									dataSource.update(job);	
									periodicalWorkerLog.error("Finished: " + job.getGeneratedId() + " " + job.getStatus());									
								}
							} 
							catch (Exception e) 
							{
								StackTraceElement[] stack = e.getStackTrace();
								for(int i = 0; stack != null && i < stack.length; i++)
								{
									periodicalWorkerLog.error(stack[i].toString());
								}
							}
						}
					}
					
					//retrieves status of the running/waiting/queued jobs
					Map<String, String> jobStatus = dataManager.getJobStatus(workstation.getUsername());

					//tests if a job has already been queued
					//sets new status of not finished jobs
					for(Job job: notFinishedJobs)
					{
						if( job.getStatus() != null && 
							!job.getStatus().equals(JobStatus.SUBMITTED.getStatus()) &&
							!job.getStatus().equals(JobStatus.REGISTERED.getStatus()))
						{
							if(jobStatus.containsKey(job.getWorkstationId()))
							{
								job.setStatus(jobStatus.get(job.getWorkstationId()));
							}
							else
							{
								job.setStatus(JobStatus.FINISHED_RUNNING.getStatus());
							}
							
							dataSource.update(job);	
						}
					}
					
					//process finished jobs
					JobParams jobParams			= Cache.getJobParams();
					long expirationPeriod    	= jobParams.getExpirationPeriod();
					long expirationPeriodErr	= jobParams.getExpirationPeriodErr();
 
					for(Job job: notFinishedJobs)
					{
						if(job.getStatus().equals(JobStatus.FINISHED_RUNNING.getStatus()))
						{
							try
							{
								resultsExtraction(dataManager, job, 
												  workstation.getRemoteFilePath(), 
												  workstation.getGlobalFilePath());
								
								job.setExpirationDate(getExpirationDate(expirationPeriod));
								job.setStatus(JobStatus.FINISHED.getStatus());
								dataSource.update(job);
								
								sendEmail(job, jobParams.getUrlForResults(), emailNotification.getHostname(), emailNotification.getSender());
							}
							catch (JobFailureException e)
							{
								job.setExpirationDate(getExpirationDate(expirationPeriodErr));
								job.setStatus(JobStatus.ERRORS.getStatus());
								dataSource.update(job);

								sendEmail(job, jobParams.getUrlForResults(), emailNotification.getHostname(), emailNotification.getSender());
							}
							catch (Exception e)
							{
								StackTraceElement[] stack = e.getStackTrace();
								for(int i = 0; stack != null && i < stack.length; i++)
								{
									periodicalWorkerLog.error(stack[i].toString());
								}
							}
						}
					}
				}
			}
			catch (Exception e)
			{
				StackTraceElement[] stack = e.getStackTrace();
				for(int i = 0; stack != null && i < stack.length; i++)
				{
					periodicalWorkerLog.error(stack[i].toString());
				}
			}

			try
			{
				Thread.sleep(sleep * 1000);
			}
			catch (InterruptedException e){}
		}
	}
	
	protected abstract void resultsExtraction(IDataManager dataManager, Job job, 
												String remotePath, String localPath) throws Exception;
	
	protected abstract String jobSubmission(IDataManager dataManager, boolean localWorkstation, 
											  String globalFilePath, String remoteFilePath, 
											  String jobGeneratedId, Set<DataFile> dataFiles, String jobType) 
											  throws Exception;

	private static void sendEmail(Job job, String url, String hostname, String sender)
	{
		if(job.getEmail() != null && !job.getEmail().equals(""))
		{
			String subject = null;
			if(job.getDescription() != null && !job.getDescription().equals(""))
			{
				subject = "Finished job: " + job.getDescription();
			}
			else
			{
				subject = "Finished job: " + job.getGeneratedId();
			}
			if(job.getStatus() == JobStatus.ERRORS.getStatus())
			{
				subject += " (with errors)";
			}

			String content = mailContent(job, url);

			try
			{
				SMTPMailService.send(sender, job.getEmail(), content, subject, hostname);
			}
			catch (Exception e)
			{
				StackTraceElement[] stack = e.getStackTrace();
				for(int i = 0; stack != null && i < stack.length; i++)
				{
					periodicalWorkerLog.error(stack[i].toString());
				}
			}
		}
	}

	private static String mailContent(Job job, String url)
	{
		String info =	"PDEXK server\n\n" +
						"Job submission date: " + job.getSubmissionDate() + ".\n" +
						"Job expiration date: " + job.getExpirationDate() + ".\n";
		
		if(job.getDescription() != null)
		{
			info += "Job description: " + job.getDescription() + ".\n";
		}
		
		if(url != null)
		{
			info += "The results can be found here:\n" + url + job.getGeneratedId();
		}

		return info;
	}

	private static Date getExpirationDate(long days)
	{
		Date date = new Date();

		date.setTime(date.getTime() + (1000L * 60L) * 60L * 24L * days);

		return date;
	}

	public boolean isRun()
	{
		return run;
	}

	public void setRun(boolean run)
	{
		this.run = run;
	}

}
