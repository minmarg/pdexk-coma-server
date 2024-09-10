package PDEXKsvm.pages.edit;

import org.apache.tapestry5.annotations.Component;
import org.apache.tapestry5.annotations.InjectPage;
import org.apache.tapestry5.annotations.Persist;
import org.apache.tapestry5.annotations.Property;
import org.apache.tapestry5.annotations.SessionState;
import org.apache.tapestry5.corelib.components.Form;
import org.apache.tapestry5.ioc.annotations.Inject;

import PDEXKsvm.cache.Cache;
import PDEXKsvm.entities.JobParams;
import PDEXKsvm.entities.User;
import PDEXKsvm.pages.Index;
import PDEXKsvm.pages.Info;
import PDEXKsvm.services.IDataSource;

public class EditJobParams 
{
	@Property
    @SessionState(create=false)
    private User user;

	@Inject
	private IDataSource dataSource;
	
	Object onActivate()
	{
		if(user != null && user.isAdmin())
		{
			return null;
		}
		
		return Index.class;
	}
	
	@InjectPage
	private Info infoPage;
	
	@Component(id = "editJobParamsForm")
	private Form editJobParamsForm;
	
	@Persist
	private JobParams jobParams;
	
	public JobParams getJobParams() throws Exception 
	{
		if(jobParams == null)
		{
			jobParams = Cache.getJobParams();
		}
		return jobParams;
	}

	public void setJobParams(JobParams jobParams) {
		this.jobParams = jobParams;
	}

	Object onSuccess()
	{
		if(!editJobParamsForm.getHasErrors())
		{
			try 
			{
				dataSource.update(jobParams);
				
				Cache.refreshJobParams();
			} 
			catch (Exception e) 
			{
				editJobParamsForm.recordError("Updating failed because of database error!");
				e.printStackTrace();
			}
		}
		
		if(!editJobParamsForm.getHasErrors())
		{
			infoPage.setInfo("Updated successfully!");
			
			return infoPage;
		}
		
		return null;
	}

	public IDataSource getDataSource() {
		return dataSource;
	}

	public void setDataSource(IDataSource dataSource) {
		this.dataSource = dataSource;
	}
}
