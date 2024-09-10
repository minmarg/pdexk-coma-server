package PDEXKsvm.dataManagement.periodical;

import java.io.File;
import java.util.List;
import java.util.Map;
import java.util.TimerTask;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;

import PDEXKsvm.cache.Cache;
import PDEXKsvm.dataManagement.JobStatus;
import PDEXKsvm.dataManagement.transfer.IDataManager;
import PDEXKsvm.dataManagement.transfer.LocalPBSDataManager;
import PDEXKsvm.dataManagement.transfer.PublicKeyAuthentication;
import PDEXKsvm.dataManagement.transfer.RemotePBSDataManager;
import PDEXKsvm.entities.Job;
import PDEXKsvm.entities.Workstation;
import PDEXKsvm.services.IDataSource;

public class PeriodicalGarbageCollector  extends TimerTask 
{
	private static final Logger periodicalGarbageCollectorLog = 
								Logger.getLogger("periodicalGarbageCollector");
	
	private boolean run = true;

	private IDataSource dataSource 		= null;
	private IDataManager dataManager 	= null;
	private long period = 1;
	
	public PeriodicalGarbageCollector(IDataSource dataSource)
	{
		this.dataSource = dataSource;
	}
	
	public void run() 
	{
		while(run)
		{
			try
			{
				//Status equals CANCELED or expiration date is less then NOW
				List<Job> expiredJobs = dataSource.getExpiredJobs();
				
				if(expiredJobs != null && expiredJobs.size() > 0)
				{
					Workstation workstation = Cache.getWorkstation();
					
					if(workstation.isLocal())
					{
						dataManager = new LocalPBSDataManager();
					}
					else
					{
						dataManager = new RemotePBSDataManager(PublicKeyAuthentication.connect(workstation.getUsername(), 
								workstation.getHostname(), workstation.getKeyFilePath(), workstation.getKeyfilePass()));
					}
					
					for(Job job: expiredJobs)
					{
						try 
						{
							if(job.getStatus().equals(JobStatus.CANCELED.getStatus()))
							{
								dataManager.cancelJob(job.getWorkstationId());
							}
						} 
						catch (Exception e) 
						{
							StackTraceElement[] stack = e.getStackTrace();
							
							for(int i = 0; stack != null && i < stack.length; i++)
							{
								periodicalGarbageCollectorLog.error(stack[i].toString());	
							}
						}
					}
					
					//retrieves status of the running/waiting/queued jobs
					Map<String, String> jobStatus = dataManager.getJobStatus(workstation.getUsername());
					
					for(Job job: expiredJobs)
					{
						try 
						{
							if(!jobStatus.containsKey(job.getWorkstationId()))
							{
								if(!workstation.isLocal())
								{
									dataManager.deleteDir(workstation.getRemoteFilePath() + job.getGeneratedId());
								}
								
								File file = new File(workstation.getGlobalFilePath() + job.getGeneratedId());
								
								if(file.exists())
								{
									FileUtils.forceDelete(file);	
								}

								dataSource.delete(job);
							}
						} 
						catch (Exception e) 
						{
							StackTraceElement[] stack = e.getStackTrace();
							
							for(int i = 0; stack != null && i < stack.length; i++)
							{
								periodicalGarbageCollectorLog.error(stack[i].toString());	
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
					periodicalGarbageCollectorLog.error(stack[i].toString());	
				}
			}

			try 
			{
				Thread.sleep(1000L * 60L * 60L * period);
			} 
			catch (InterruptedException e){}
		}
		
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
