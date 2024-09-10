package PDEXKsvm.pages;

import org.apache.tapestry5.annotations.SessionState;
import org.apache.tapestry5.ioc.annotations.Inject;

import PDEXKsvm.entities.User;
import PDEXKsvm.services.IDataSource;

public class Administrator 
{
	private String username;
	private String password;
	
	@Inject
	private IDataSource dataSource;
	@SessionState(create=false)
    private User user;
	
	Object onSuccess() throws Exception
	{
		user = dataSource.getUser(username, password);
		
		return Index.class;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}
}
