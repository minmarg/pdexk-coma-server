package PDEXKsvm.components;

import java.util.List;

import org.apache.tapestry5.*;
import org.apache.tapestry5.annotations.*;
import org.apache.tapestry5.ioc.annotations.*;
import org.apache.tapestry5.services.Cookies;
import org.apache.tapestry5.BindingConstants;

import util.CookieManager;

import PDEXKsvm.entities.Job;
import PDEXKsvm.entities.RecentJobs;
import PDEXKsvm.entities.User;
import PDEXKsvm.pages.Index;
import PDEXKsvm.pages.Wait;
import PDEXKsvm.services.IDataSource;

/**
 * Layout component for pages of application PDEXKsvm.
 */
@IncludeStylesheet("context:layout/layout.css")
public class Layout
{
    /** The page title, for the <title> element and the <h1> element. */
    @Property
    @Parameter(required = true, defaultPrefix = BindingConstants.LITERAL)
    private String title;
    
    @Inject 
	private IDataSource dataSource;
    @Inject
    private Cookies cookies;
    
    @Property
    private Job job = null;
    
    @SessionState
    private RecentJobs recentJobs;
    private boolean recentJobsExists;
    
    @Property
    private String pageName;
    @Property
    @SessionState
    private User user;
    
    @Inject
    private ComponentResources resources;

    public String getClassForPageName()
    {
      return resources.getPageName().equalsIgnoreCase(pageName)
             ? "current_page_item"
             : null;
    }

    public String[] getPageNames()
    {
    	if(user != null && user.isAdmin())
    	{
    		return new String[] {"Contact"};
    	}

    	return new String[] {"Administrator", "Contact"};
    }
    
    @InjectPage
    private Wait waiter;
    
    Object onActionFromRecentJob(String id)
    {
    	waiter.init(id);
    	
        return waiter;
    }

    
    Object onActionFromLogout()
    {
    	user = null;
    	
        return Index.class;
    }

	public RecentJobs getRecentJobs() 
	{
		if(!recentJobsExists)
		{
			List<Job> jobs = CookieManager.getJobs(dataSource, cookies);
			for(Job job: jobs)
			{
				recentJobs.addJob(job);
			}
		}
		
		return recentJobs;
	}

	public void setRecentJobs(RecentJobs recentJobs) {
		this.recentJobs = recentJobs;
	}
}
