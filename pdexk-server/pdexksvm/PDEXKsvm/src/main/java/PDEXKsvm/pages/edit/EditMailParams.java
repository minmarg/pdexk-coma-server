package PDEXKsvm.pages.edit;

import org.apache.tapestry5.annotations.Component;
import org.apache.tapestry5.annotations.InjectPage;
import org.apache.tapestry5.annotations.Persist;
import org.apache.tapestry5.annotations.Property;
import org.apache.tapestry5.annotations.SessionState;
import org.apache.tapestry5.corelib.components.Form;
import org.apache.tapestry5.ioc.annotations.Inject;

import PDEXKsvm.cache.Cache;
import PDEXKsvm.entities.EmailNotification;
import PDEXKsvm.entities.User;
import PDEXKsvm.pages.Index;
import PDEXKsvm.pages.Info;
import PDEXKsvm.services.IDataSource;


public class EditMailParams 
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
	
	@Component(id = "editEmailForm")
	private Form editEmailForm;
	
	@Persist
	private EmailNotification emailNotification;
	
	Object onSuccess()
	{
		if(!editEmailForm.getHasErrors())
		{
			try 
			{
				dataSource.update(emailNotification);
				
				Cache.refreshEmailNotificationParams();
			} 
			catch (Exception e) 
			{
				editEmailForm.recordError("Updating failed because of database error!");
				e.printStackTrace();
			}
		}
		
		if(!editEmailForm.getHasErrors())
		{
			infoPage.setInfo("Updated successfully!");
			
			return infoPage;
		}
		
		return null;
	}

	public EmailNotification getEmailNotification() throws Exception 
	{
		if(emailNotification == null)
		{
			emailNotification = Cache.getEmailNotificationParams();
		}
		return emailNotification;
	}

	public void setEmailNotification(EmailNotification emailNotification) {
		this.emailNotification = emailNotification;
	}

	public IDataSource getDataSource() {
		return dataSource;
	}

	public void setDataSource(IDataSource dataSource) {
		this.dataSource = dataSource;
	}
}
