package PDEXKsvm.pages;

import java.io.File;
import java.text.DecimalFormat;
import java.util.Iterator;

import org.apache.tapestry5.annotations.InjectPage;
import org.apache.tapestry5.ioc.annotations.Inject;
import org.apache.tapestry5.services.Request;

import PDEXKsvm.cache.Cache;
import PDEXKsvm.dataManagement.JobStatus;
import PDEXKsvm.entities.ClassificationObject;
import PDEXKsvm.entities.Job;
import PDEXKsvm.enums.Extensions;
import PDEXKsvm.services.IDataSource;

public class Results 
{
	@Inject
	private Request request;
	
	private ClassificationObject classObj;
	
	@Inject
	private IDataSource dataSource;
	
	private String generatedId;
	
	public void init(String id)
	{
		generatedId = id;
	}
	
	@InjectPage
	private Error error;
	
	private Job job;
	
	Object onActivate()
	{
		if(generatedId == null || generatedId.equals(""))
		{
			error.setError("Incorrect job id!");
			return error;
		}
		
		return null;
	}
	
	@InjectPage
	private Wait wait;
	
	Object onActivate(String id)
	{
		generatedId = id;
		
		if(generatedId == null || generatedId.equals(""))
		{
			error.setError("Incorrect job id!");
			return error;
		}
			
		try 
		{
			job = dataSource.getJob(generatedId);
		} 
		catch (Exception e) 
		{
			error.setError(e.getMessage());
			e.printStackTrace();
			return error;
		}
		
		if(job == null)
		{
			error.setError("Incorrect job id!");
			return error;
		}
		
		if(!job.getStatus().equals(JobStatus.FINISHED.getStatus()) && 
				!job.getStatus().equals(JobStatus.ERRORS.getStatus()))
		{
			wait.init(generatedId);
			return wait;
		}

		return null;
	}
	
	String onPassivate()
	{
		return generatedId;
	}

	public Job getJob() {
		return job;
	}

	public void setJob(Job job) {
		this.job = job;
	}

	public Request getRequest() {
		return request;
	}

	public void setRequest(Request request) {
		this.request = request;
	}
	
	public String getInputDataPath() throws Exception
	{
		return getPath(Extensions.INPUT_FASTA.getExtension());
	}
	
	public String getInputParamsPath() throws Exception
	{
		return getPath(Extensions.INPUT_PARAMS.getExtension());
	}
	
	public String getSTDERRLogPath() throws Exception
	{
		return getPath(Extensions.LOG_STDERR.getExtension());
	}
	
	public String getSTDOUTLogPath() throws Exception
	{
		return getPath(Extensions.LOG_STDOUT.getExtension());
	}
	
	public String getFinalMSAPath() throws Exception
	{
		return getPath(Extensions.OUTPUT_FINAL_MSA_FASTA.getExtension());
	}
	
	public String getComparisonOfMSAPath() throws Exception
	{
		return getPath(Extensions.OUTPUT_COMPARISON_OF_MSA.getExtension());
	}
	
	public String getAlignedPDEXKPath() throws Exception
	{
		File file = new File(Cache.getWorkstation().getGlobalFilePath() +
				job.getGeneratedId() + File.separator + job.getGeneratedId() +
				Extensions.OUTPUT_ALIGNED_PDEXK.getExtension());
		if(file.length() <= 0)
		{
			return null;
		}
		return getPath(Extensions.OUTPUT_ALIGNED_PDEXK.getExtension());
	}
	
	public String getSVMProbabilityPath() throws Exception
	{
		return getPath(Extensions.OUTPUT_SVM_PROBABILITY.getExtension());
	}
	
	private String getPath(String extension) throws Exception
	{
		return request.getContextPath() + "/" + 
				Cache.getWorkstation().getLocalFilePath() + "/" +
				job.getGeneratedId() + "/" +
				job.getGeneratedId() + extension;
	}
	
	private static double calcPredictedProbability(Job job)
	{
		double prob = 0.0;
		
		Iterator<ClassificationObject> classIterator = job.getClassificationObjects().iterator();
		
		int counter = 0;
		while(classIterator.hasNext())
		{
			ClassificationObject o = classIterator.next();
			try 
			{
				prob += Double.parseDouble(o.getPredictedProbability());
				counter++;
			} 
			catch (NumberFormatException e) {}
		}
		
		DecimalFormat twoDForm = new DecimalFormat("#.##");
		
		return Double.parseDouble(twoDForm.format(prob / counter));
	}
	
	public String getPredictedProbability()
	{
		return String.valueOf(calcPredictedProbability(job));
	}
	
	public boolean isGreen() throws Exception
	{
		double prob = calcPredictedProbability(job);
		if(prob >= Cache.getJobParams().getPdexkProbability())
		{
			return true;
		}
		
		return false;
	}
	
	public boolean isBlue() throws Exception
	{
		double prob = calcPredictedProbability(job);
		if(prob >= 0.5 && prob < Cache.getJobParams().getPdexkProbability())
		{
			return true;
		}
		
		return false;
	}
	
	public boolean isRed() throws Exception
	{
		double prob = calcPredictedProbability(job);
		if(prob < 0.5)
		{
			return true;
		}
		
		return false;
	}
	
	public boolean warnAboutNumberOfSequences() throws Exception
	{
		if(job.getNumberofSeq() <= Cache.getJobParams().getNumberOfSequencesInFinalMSA())
		{
			return true;
		}
		return false;
	}
	
	public ClassificationObject getClassObj() {
		return classObj;
	}

	public void setClassObj(ClassificationObject classObj) {
		this.classObj = classObj;
	}
}
