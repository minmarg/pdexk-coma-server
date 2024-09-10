package PDEXKsvm.pages.edit;

import org.apache.tapestry5.annotations.Component;
import org.apache.tapestry5.annotations.InjectPage;
import org.apache.tapestry5.annotations.OnEvent;
import org.apache.tapestry5.annotations.Property;
import org.apache.tapestry5.annotations.SessionState;
import org.apache.tapestry5.corelib.components.Form;
import org.apache.tapestry5.corelib.components.PasswordField;
import org.apache.tapestry5.ioc.annotations.Inject;


import PDEXKsvm.dataManagement.PasswordManager;
import PDEXKsvm.entities.User;
import PDEXKsvm.pages.Index;
import PDEXKsvm.pages.Info;
import PDEXKsvm.services.IDataSource;

public class EditUser 
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
	
	private String password;
	private String retypedPassword;
	
	@Component
	private Form editUserForm;
	@Component(id = "password")
	private PasswordField passwordField;

	@OnEvent(component="editUserForm")
	Object onSuccess()
	{
		boolean error = false;
		
		if(password != null && retypedPassword != null)
		{
			if(password.equals(retypedPassword))
			{
				if(!password.equals(""))
				{
					try 
					{
						user.setPassword(PasswordManager.encrypt(password));
					} 
					catch (Exception e) 
					{
						e.printStackTrace();
						editUserForm.recordError("Updating failed because of encryption error!");
					}
				}
			}
			else
			{
				error = true;
				
				password = null;
				retypedPassword = null;
				editUserForm.recordError(passwordField, "Passwords do not match.");
			}
		}
		
		if(!editUserForm.getHasErrors())
		{
			try 
			{
				dataSource.update(user);
			} 
			catch (Exception e) 
			{
				error = true;
				
				e.printStackTrace();
				editUserForm.recordError("Updating failed because of database error!");
			}
		}
		else
		{
			error = true;
		}
		
		if(!error)
		{
			infoPage.setInfo("Updated successufully!");
			return infoPage;
		}
		
		return null;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getRetypedPassword() {
		return retypedPassword;
	}

	public void setRetypedPassword(String retypedPassword) {
		this.retypedPassword = retypedPassword;
	}
	
}
