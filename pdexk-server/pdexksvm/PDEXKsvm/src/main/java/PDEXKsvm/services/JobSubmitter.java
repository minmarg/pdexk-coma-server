package PDEXKsvm.services;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.log4j.Logger;

import PDEXKsvm.cache.Cache;
import PDEXKsvm.dataManagement.JobStatus;
import PDEXKsvm.dataManagement.PasswordManager;
import PDEXKsvm.entities.DataFile;
import PDEXKsvm.entities.Job;
import PDEXKsvm.entities.JobParams;
import PDEXKsvm.entities.Workstation;
import PDEXKsvm.enums.Extensions;
import PDEXKsvm.enums.InputType;
import PDEXKsvm.enums.JobType;
import PDEXKsvm.enums.SearchStrategy;
import PDEXKsvm.services.IDataSource;

public class JobSubmitter
{
	private static final Logger jobSubmitterLog = Logger.getLogger("jobSubmitter");
	private static IDataSource dataSource;

	private JobSubmitter(){}
	
	public static synchronized void setDataSource(IDataSource source)
	{
		dataSource = source;
	}
	
	public static synchronized Job submit(	List<String> data, 
												String description,
												String email,
												InputType type,
												SearchStrategy searchStrategy) throws  Exception
	{
		JobParams jobParams = Cache.getJobParams();
		Workstation workstation = Cache.getWorkstation();
		
		Job job = null;
		
		try 
		{
			job = registerJob(dataSource, description, email, jobParams.getMaxSubmittedJobs());

			commonTasks(dataSource, job, workstation.getGlobalFilePath());
			
			String globalPathToData = workstation.getGlobalFilePath() + job.getGeneratedId();

			/*
			 * 
			 * specific to this concrete job
			 * 
			 * */
			job.setType(JobType.PDEXK.getType());
			
			data2file(globalPathToData + File.separator + job.getGeneratedId() + type.getExtension(), data);

			List<String> params = new ArrayList<String>();
			params.add("INPUT_TYPE=" + type.getName());
			params.add("SEARCH_STRATEGY=" + searchStrategy.getValue());
			
			data2file(globalPathToData + File.separator + job.getGeneratedId() + Extensions.INPUT_PARAMS.getExtension(), params);

			//files to send to workstation
			job.getDataFiles().add(new DataFile(job.getGeneratedId() + type.getExtension(), DataFile.INPUT));
			job.getDataFiles().add(new DataFile(job.getGeneratedId() + Extensions.INPUT_PARAMS.getExtension(), DataFile.INPUT));
			//files to download from workstation
			//logs
			job.getDataFiles().add(new DataFile(job.getGeneratedId() + Extensions.LOG_STDOUT.getExtension(), DataFile.OUTPUT));
			job.getDataFiles().add(new DataFile(job.getGeneratedId() + Extensions.LOG_STDERR.getExtension(), DataFile.OUTPUT));
			//output
			job.getDataFiles().add(new DataFile(job.getGeneratedId() + Extensions.OUTPUT_COMPARISON_OF_MSA.getExtension(), DataFile.OUTPUT));
			job.getDataFiles().add(new DataFile(job.getGeneratedId() + Extensions.OUTPUT_ALIGNED_PDEXK.getExtension(), DataFile.OUTPUT));
			job.getDataFiles().add(new DataFile(job.getGeneratedId() + Extensions.OUTPUT_FINAL_MSA_FASTA.getExtension(), DataFile.OUTPUT));
			job.getDataFiles().add(new DataFile(job.getGeneratedId() + Extensions.OUTPUT_SVM_PROBABILITY.getExtension(), DataFile.OUTPUT));
			
			job.setStatus(JobStatus.SUBMITTED.getStatus());
			
			dataSource.update(job);
		} 
		catch (Exception e) 
		{
			if(job != null)
			{
				job.setStatus(JobStatus.ERRORS.getStatus());
				job.setError(e.getMessage());
				job.setExpirationDate(getDate(jobParams.getExpirationPeriodErr()));
				dataSource.update(job);	
			}
			
			StackTraceElement[] stack = e.getStackTrace();
			for(int i = 0; stack != null && i < stack.length; i++)
			{
				jobSubmitterLog.error(stack[i].toString());
			}

			throw e;
		}
		
		return job;
	}

	private static synchronized void data2file(String filePath, List<String> data) throws Exception
	{
		FileWriter fstream = new FileWriter(filePath);
		BufferedWriter out = new BufferedWriter(fstream);
		
		for(String line: data)
		{
			out.write(line + "\n");
		}
		
		out.close();
	}
	
	private static synchronized Date getDate(long days)
	{
		Date date = new Date();

		date.setTime(date.getTime() + (1000L * 60L) * 60L * 24L * days);

		return date;
	}
	
	private static synchronized Job registerJob(	IDataSource dataSource, 
													String description, 
													String email,
													int maxSubmittedJobs) throws  Exception
	{
		long activeJobs = dataSource.activeJobNumber();
		if(maxSubmittedJobs <= activeJobs)
		{
			throw new Exception("There are too many submitted jobs: " + activeJobs + "!");
		}
		
		Job job = new Job();
		
		job.setDescription(description);
		job.setEmail(email);
		job.setSubmissionDate(getDate(0));
		
		dataSource.save(job);
		
		return job;
	}
	
	private static synchronized void commonTasks(IDataSource dataSource, Job job, String globalFilePath) throws Exception
	{
		String generatedId = PasswordManager.encrypt(String.valueOf(job.getId()));
		job.setGeneratedId(generatedId);
				
		job.setStatus(JobStatus.REGISTERED.getStatus());
		
		dataSource.update(job);
		
		makeLocalDir(globalFilePath + generatedId);
	}

	private static synchronized void makeLocalDir(String path) throws Exception
	{
		File file = new File(path);
		
		if(!file.exists())
		{
			boolean success = file.mkdirs();
			
			if(!success)
			{
				throw new Exception("ERR: failed creating directory: " + path);
			}
		}
		else
		{
			throw new Exception("ERR: the directory was created before: " + path);
		}
	}
}
