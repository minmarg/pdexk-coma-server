package PDEXKsvm.services;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import PDEXKsvm.cache.Cache;
import PDEXKsvm.dataManagement.periodical.AbstractPeriodicalWorker;
import PDEXKsvm.dataManagement.transfer.IDataManager;
import PDEXKsvm.entities.ClassificationObject;
import PDEXKsvm.entities.DataFile;
import PDEXKsvm.entities.Job;
import PDEXKsvm.enums.Extensions;
import PDEXKsvm.enums.JobType;
import PDEXKsvm.exceptions.JobFailureException;

public class PDEXKrecPeriodicalWorker extends AbstractPeriodicalWorker 
{
	public PDEXKrecPeriodicalWorker(IDataSource dataSource) 
	{
		super(dataSource);
	}
	
	protected String jobSubmission(IDataManager dataManager, boolean localWorkstation, String globalFilePath, 
									String remoteFilePath, String jobGeneratedId, 
									Set<DataFile> dataFiles, String jobType) throws Exception
	{
		String command = null;
		if(jobType.equals(JobType.PDEXK.getType()))
		{
			command = Cache.getWorkstation().getScriptPath();
		}
		else
		{
			throw new Exception("Don't know the job type: " + jobType);
		}
		
		String workstationId = null;
		
		if(localWorkstation)
		{
			command = command + " " + jobGeneratedId + " " + globalFilePath + jobGeneratedId;
			
			workstationId = dataManager.submitJob(command);
		}
		else
		{
			String remoteJobDir = remoteFilePath + jobGeneratedId;
			
			dataManager.createDir(remoteJobDir);
			
			List<String> files = new ArrayList<String>();
			
			for(DataFile file: dataFiles)
			{
				if(file.getType().equals(DataFile.INPUT))
				{
					files.add(globalFilePath + jobGeneratedId + File.separator + file.getPath());					
				}
			}
		
			dataManager.sendData(files, remoteJobDir);
			
			command = command + " " + jobGeneratedId + " " + remoteFilePath + jobGeneratedId;
			
			workstationId = dataManager.submitJob(command);
		}
		
		return workstationId;
	}
	
	protected void resultsExtraction(IDataManager dataManager, Job job, 
									   String remotePath, String localPath) throws Exception
	{
		List<String> files = new ArrayList<String>();
		
		for(DataFile file: job.getDataFiles())
		{
			if(file.getType().equals(DataFile.OUTPUT))
			{
				String filePath = remotePath + job.getGeneratedId() + "/" + file.getPath();
				if(dataManager.fileExists(filePath))
				{
					files.add(filePath);	
				}					
			}
		}
		
		dataManager.retieveData(files, localPath + job.getGeneratedId());
		
		String errorMsg = getErrorInfo(localPath + job.getGeneratedId() + File.separator + job.getGeneratedId() + Extensions.LOG_STDERR.getExtension());
		if(!errorMsg.equals(""))
		{
			job.setError(errorMsg);
			throw new JobFailureException("Job ID: " + job.getGeneratedId());
		}
		
		job.setClassificationObjects(getClassificationInfo(localPath + job.getGeneratedId() + File.separator + job.getGeneratedId() + Extensions.OUTPUT_SVM_PROBABILITY.getExtension()));
		job.setNumberofSeq(calcSequences(localPath + job.getGeneratedId() + File.separator + job.getGeneratedId() + Extensions.OUTPUT_FINAL_MSA_FASTA.getExtension()));
	}
	
	private static int calcSequences(String path) throws IOException
	{
		List<String> data = readFile(path);
		
		int counter = 0;
		
		for(String line: data)
		{
			if(line.matches("^>.*"))
			{
				counter++;	
			}
		}
		
		//substracts ss_pred and ss_conf
		counter -= 2;
		
		return counter;
		
	}

	private static Set<ClassificationObject> getClassificationInfo(String path) throws IOException
	{
		Set<ClassificationObject> info = new HashSet<ClassificationObject>();
		
		List<String> data = readFile(path);
		
		Pattern pattern = Pattern.compile("^.*training_acc:(\\S+)\\s+predicted_prob:(\\S+).*$");
		
		for(String line: data)
		{
			Matcher m = pattern.matcher(line);
			
			if(m.matches())
        	{
				ClassificationObject classObj = new ClassificationObject();
				classObj.setTrainingAccuracy(m.group(1));
				classObj.setPredictedProbability(m.group(2));

                info.add(classObj);
        	}
		}
		
		return info;
	}
	
	private static String getErrorInfo(String path) throws IOException
	{
		List<String> data = readFile(path);
		
		StringBuffer buffer = new StringBuffer("");
		
		for(String line: data)
		{
			if(!line.equals(""));
			{
				buffer.append(line + "<br/>");
			}
		}
		
		return buffer.toString();
	}
	
	private static List<String> readFile(String path) throws IOException
	{
		List<String> data = new ArrayList<String>();

	    FileInputStream fstream = new FileInputStream(path);

	    DataInputStream in = new DataInputStream(fstream);
        BufferedReader br = new BufferedReader(new InputStreamReader(in));
	    String strLine;
	    while ((strLine = br.readLine()) != null)   
	    {
	      data.add(strLine);
	    }
	    in.close();
	    
		return data;
	}

}
