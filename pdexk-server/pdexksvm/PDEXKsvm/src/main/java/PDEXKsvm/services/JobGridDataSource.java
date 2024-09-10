package PDEXKsvm.services;

import java.util.List;

import org.apache.tapestry5.grid.GridDataSource;
import org.apache.tapestry5.grid.SortConstraint;

import PDEXKsvm.entities.Job;


public class JobGridDataSource implements GridDataSource 
{
	private List<Job> selectedJobs = null;
	private int start = 0;
	private IDataSource dataSource = null;
	
	
	public JobGridDataSource(IDataSource dataSource)
	{
		this.dataSource = dataSource;
	}
	
	public int getAvailableRows() 
	{
		int jobNumber = 0;
			
		try 
		{
			Long tmp = dataSource.activeJobNumber();
			jobNumber = tmp.intValue();
		} 
		catch (Exception e) 
		{
			e.printStackTrace();
		}

		return jobNumber;
	}

	public Class getRowType() 
	{
		return Job.class;
	}

	public Object getRowValue(int index) 
	{
		return selectedJobs.get(index - start);
	}

	public void prepare(int startIndex, int endIndex, List<SortConstraint> sortConstraints) 
	{
    	try
    	{
    		selectedJobs = dataSource.getJobs(startIndex, endIndex, sortConstraints);
			start = startIndex;
		}
    	catch (Exception e)
    	{
    		e.printStackTrace();
		}
	}

}
