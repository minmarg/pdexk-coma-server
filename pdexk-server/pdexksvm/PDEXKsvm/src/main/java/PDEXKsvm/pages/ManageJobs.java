package PDEXKsvm.pages;

import org.apache.tapestry5.annotations.InjectPage;
import org.apache.tapestry5.annotations.Property;
import org.apache.tapestry5.annotations.SessionState;
import org.apache.tapestry5.grid.GridDataSource;
import org.apache.tapestry5.ioc.annotations.Inject;

import PDEXKsvm.dataManagement.JobStatus;
import PDEXKsvm.entities.Job;
import PDEXKsvm.entities.User;
import PDEXKsvm.services.IDataSource;
import PDEXKsvm.services.JobGridDataSource;

public class ManageJobs 
{
	@Property
    @SessionState(create=false)
    private User user;

	@Inject
	private IDataSource dataSource;
	
	public GridDataSource getJobGridDataSource()
	{
		return new JobGridDataSource(dataSource);
	}
	
	Object onActivate()
	{
		if(user != null && user.isAdmin())
		{
			return null;
		}
		
		return Index.class;
	}

	private Job job;
	
	public void setJob(Job job) {
		this.job = job;
	}

	public Job getJob() {
		return job;
	}
	
	@InjectPage
	private Results resultsPage;
	
	Object onActionFromView(String id)
    {
		resultsPage.init(id);
        return resultsPage;
    } 
	
	void onActionFromDelete(String id) throws Exception
    {
		Job job = dataSource.getJob(id);
		if(job != null && user != null && user.isAdmin())
		{
			job.setStatus(JobStatus.CANCELED.getStatus());
			dataSource.update(job);
		}
    }
}
