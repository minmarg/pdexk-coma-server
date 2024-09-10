package PDEXKsvm.cache;

import PDEXKsvm.entities.EmailNotification;
import PDEXKsvm.entities.JobParams;
import PDEXKsvm.entities.Workstation;
import PDEXKsvm.services.IDataSource;


public class Cache 
{
	private static IDataSource dataSource = null;

	private static EmailNotification emailNotificationParams = null;
	private static JobParams jobParams = null;
	private static Workstation workstation = null;
	
	private Cache(){}
	
	public static synchronized void setDataSource(IDataSource source)
	{
		dataSource = source;
	}
	
	public static synchronized void refreshEmailNotificationParams()
	{
		emailNotificationParams = null;
	}
	
	public static synchronized EmailNotification getEmailNotificationParams() throws Exception
	{
		if(emailNotificationParams == null)
		{
			emailNotificationParams = dataSource.getEmailParams();
		}
		return emailNotificationParams;
	}
	
	public static synchronized void refreshJobParams()
	{
		jobParams = null;
	}
	
	public static synchronized JobParams getJobParams() throws Exception
	{
		if(jobParams == null)
		{
			jobParams = dataSource.getJobParams();
		}
		return jobParams;
	}
	
	public static synchronized void refreshWorkstation()
	{
		workstation = null;
	}
	
	public static synchronized Workstation getWorkstation() throws Exception
	{
		if(workstation == null)
		{
			workstation = dataSource.getWorkstation();
		}
		return workstation;
	}
}
