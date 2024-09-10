package PDEXKsvm.services;

import java.util.Timer;

import javax.servlet.ServletException;

import org.apache.tapestry5.TapestryFilter;
import org.apache.tapestry5.ioc.Registry;

import PDEXKsvm.cache.Cache;
import PDEXKsvm.dataManagement.periodical.AbstractPeriodicalWorker;
import PDEXKsvm.dataManagement.periodical.PeriodicalGarbageCollector;
import PDEXKsvm.dataManagement.transfer.PublicKeyAuthentication;


public class WebServerFilter extends TapestryFilter
{
	private IDataSource dataSource = null;
	private AbstractPeriodicalWorker periodicalWorker = null;
	private Timer periodicalWorkerJob 		   = null;
	
	private PeriodicalGarbageCollector periodicalGarbageCollector = null;
	private Timer periodicalGarbageCollectorJob 				   = null;
	
	public WebServerFilter()
	{
		dataSource = new HibernateDataSource();
		
		Cache.setDataSource(dataSource);
		JobSubmitter.setDataSource(dataSource);
		
		periodicalWorkerJob = new Timer();
		periodicalWorker    = new PDEXKrecPeriodicalWorker(dataSource);
		
		periodicalGarbageCollectorJob = new Timer();
		periodicalGarbageCollector 	  = new PeriodicalGarbageCollector(dataSource);
	}
	
	protected void init(Registry registry) throws ServletException
	{
		super.init(registry);
		
		try 
		{
			dataSource.init();
		} 
		catch (Exception e) 
		{
			e.printStackTrace();
		}
		
		periodicalWorkerJob.schedule(periodicalWorker, 0);
		periodicalGarbageCollectorJob.schedule(periodicalGarbageCollector, 0);
	}
	
	protected void destroy(Registry registry)
	{
		super.destroy(registry);
		
		periodicalWorker.setRun(false);
		periodicalWorkerJob.cancel();
		
		periodicalGarbageCollector.setRun(false);
		periodicalGarbageCollectorJob.cancel();
		
		PublicKeyAuthentication.disconnect();
	}
}
