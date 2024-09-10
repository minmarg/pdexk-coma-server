package PDEXKsvm.pages.edit;

import org.apache.tapestry5.annotations.Component;
import org.apache.tapestry5.annotations.InjectPage;
import org.apache.tapestry5.annotations.Persist;
import org.apache.tapestry5.annotations.Property;
import org.apache.tapestry5.annotations.SessionState;
import org.apache.tapestry5.corelib.components.Form;
import org.apache.tapestry5.ioc.annotations.Inject;


import ch.ethz.ssh2.Connection;

import PDEXKsvm.cache.Cache;
import PDEXKsvm.dataManagement.transfer.PublicKeyAuthentication;
import PDEXKsvm.entities.User;
import PDEXKsvm.entities.Workstation;
import PDEXKsvm.pages.Index;
import PDEXKsvm.pages.Info;
import PDEXKsvm.services.IDataSource;

public class EditWorkstationParams 
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
	
	@Component(id = "editWorkstationForm")
	private Form editWorkstationForm;
	
	@Persist
	private Workstation workstation;
	
	Object onSuccess()
	{
		if(!editWorkstationForm.getHasErrors())
		{
			try 
			{
				dataSource.update(workstation);
				
				Cache.refreshWorkstation();
				
				if(!workstation.isLocal())
				{
					try 
					{
						Connection conn = PublicKeyAuthentication.connect(workstation.getUsername(), 
								workstation.getHostname(), workstation.getKeyFilePath(), workstation.getKeyfilePass());
						if(conn != null)
						{
							conn.close();	
						}
					} 
					catch (Exception e) 
					{
						editWorkstationForm.recordError("Cannot connect to the workstation!");
						e.printStackTrace();
					}
				}
			} 
			catch (Exception e) 
			{
				editWorkstationForm.recordError("Updating failed because of database error!");
				e.printStackTrace();
			}	
		}
		
		if(!editWorkstationForm.getHasErrors())
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

	public Workstation getWorkstation() throws Exception 
	{
		if(workstation == null)
		{
			workstation = Cache.getWorkstation();
		}
		return workstation;
	}

	public void setWorkstation(Workstation workstation) {
		this.workstation = workstation;
	}
}
