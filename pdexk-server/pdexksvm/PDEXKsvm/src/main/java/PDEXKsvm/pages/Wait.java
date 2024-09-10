package PDEXKsvm.pages;

import org.apache.tapestry5.annotations.InjectPage;
import org.apache.tapestry5.annotations.Persist;
import org.apache.tapestry5.ioc.annotations.Inject;

import PDEXKsvm.dataManagement.JobStatus;
import PDEXKsvm.entities.Job;
import PDEXKsvm.services.IDataSource;

public class Wait 
{
	@Inject
	private IDataSource dataSource;
	
	private String generatedId;
	@Persist
	private int timer;
	
	public void init(String id)
	{
		generatedId = id;
		timer = 0;
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
	private Results results;
	
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
		
		if(job == null || job.getStatus().equals(JobStatus.CANCELED.getStatus()))
		{
			error.setError("Incorrect job id!");
			return error;
		}
		
		if(job.getStatus().equals(JobStatus.FINISHED.getStatus()) || 
				job.getStatus().equals(JobStatus.ERRORS.getStatus()))
		{
			results.init(generatedId);
			return results;
		}
			
		if(timer < 30)
		{
			timer += 5;
		}

		return null;
	}
	
	String onPassivate()
	{
		return generatedId;
	}

	public int getTimer() {
		return timer;
	}

	public void setTimer(int timer) {
		this.timer = timer;
	}

	public Job getJob() {
		return job;
	}

	public void setJob(Job job) {
		this.job = job;
	}
}
