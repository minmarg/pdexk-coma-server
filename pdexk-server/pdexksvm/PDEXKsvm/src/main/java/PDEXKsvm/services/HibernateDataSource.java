package PDEXKsvm.services;

import java.util.ArrayList;
import java.util.List;

import org.apache.tapestry5.grid.ColumnSort;
import org.apache.tapestry5.grid.SortConstraint;
import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import PDEXKsvm.dataManagement.JobStatus;
import PDEXKsvm.dataManagement.PasswordManager;
import PDEXKsvm.entities.EmailNotification;
import PDEXKsvm.entities.Job;
import PDEXKsvm.entities.JobParams;
import PDEXKsvm.entities.User;
import PDEXKsvm.entities.Workstation;

public class HibernateDataSource implements IDataSource 
{
	private static final String USER_TABLE = " User ";
	private static final String EMAIL_TABLE = " EmailNotification ";
	private static final String JOB_PARAMS_TABLE = " JobParams ";
	private static final String WORKSTATION_TABLE = " Workstation ";
	private static final String JOB_TABLE = " Job ";
	
	public User getUser(String username, String password) throws Exception 
	{
		User user = null;
	    Transaction transaction = null;
	    Session session 		= InitSessionFactory.getInstance().getCurrentSession();

    	try
    	{
			transaction = session.beginTransaction();
			Query query = session.createQuery("from " + USER_TABLE + " o " +
					"where o.password = :password AND o.username = :username");
			query.setString("password", PasswordManager.encrypt(password));
			query.setString("username", username);

			user = (User)query.uniqueResult();

			transaction.commit();
		}
    	catch (HibernateException e)
    	{
    		if(transaction != null) transaction.rollback();
    		throw e;
		}

		return user;
	}
	
	public void update(User user) throws Exception 
	{
	    Transaction transaction = null;
	    Session session 		= InitSessionFactory.getInstance().getCurrentSession();

    	try
    	{
			transaction = session.beginTransaction();
			
			session.update(user);
			
			transaction.commit();
		}
    	catch (HibernateException e)
    	{
    		if(transaction != null) transaction.rollback();
    		throw e;
		}
	}
	
	public EmailNotification getEmailParams() throws Exception
	{
		EmailNotification params = null;
		Transaction transaction = null;
	    Session session 		= InitSessionFactory.getInstance().getCurrentSession();

    	try
    	{
			transaction = session.beginTransaction();
			Query query = session.createQuery("from " + EMAIL_TABLE + " o ");

			params = (EmailNotification)query.uniqueResult();

			transaction.commit();
		}
    	catch (HibernateException e)
    	{
    		if(transaction != null) transaction.rollback();
    		throw e;
		}
		return params;
	}
	
	public void update(EmailNotification params) throws Exception
	{
		Transaction transaction = null;
	    Session session 		= InitSessionFactory.getInstance().getCurrentSession();

    	try
    	{
			transaction = session.beginTransaction();
			
			session.update(params);
			
			transaction.commit();
		}
    	catch (HibernateException e)
    	{
    		if(transaction != null) transaction.rollback();
    		throw e;
		}
	}
	
	public JobParams getJobParams() throws Exception
	{
		JobParams params = null;
		Transaction transaction = null;
	    Session session 		= InitSessionFactory.getInstance().getCurrentSession();

    	try
    	{
			transaction = session.beginTransaction();
			Query query = session.createQuery("from " + JOB_PARAMS_TABLE + " o ");

			params = (JobParams)query.uniqueResult();

			transaction.commit();
		}
    	catch (HibernateException e)
    	{
    		if(transaction != null) transaction.rollback();
    		throw e;
		}
		return params;
	}
	
	public void update(JobParams params) throws Exception
	{
		Transaction transaction = null;
	    Session session 		= InitSessionFactory.getInstance().getCurrentSession();

    	try
    	{
			transaction = session.beginTransaction();
			
			session.update(params);
			
			transaction.commit();
		}
    	catch (HibernateException e)
    	{
    		if(transaction != null) transaction.rollback();
    		throw e;
		}
	}
	
	public Workstation getWorkstation() throws Exception
	{
		Workstation params = null;
		Transaction transaction = null;
	    Session session 		= InitSessionFactory.getInstance().getCurrentSession();

    	try
    	{
			transaction = session.beginTransaction();
			Query query = session.createQuery("from " + WORKSTATION_TABLE + " o ");

			params = (Workstation)query.uniqueResult();

			transaction.commit();
		}
    	catch (HibernateException e)
    	{
    		if(transaction != null) transaction.rollback();
    		throw e;
		}
		return params;
	}
	
	public void update(Workstation params) throws Exception
	{
		Transaction transaction = null;
	    Session session 		= InitSessionFactory.getInstance().getCurrentSession();

    	try
    	{
			transaction = session.beginTransaction();
			
			session.update(params);
			
			transaction.commit();
		}
    	catch (HibernateException e)
    	{
    		if(transaction != null) transaction.rollback();
    		throw e;
		}
	}

	public Job getJob(String id) throws Exception
	{
		Job job = null;
		Transaction transaction = null;
	    Session session 		= InitSessionFactory.getInstance().getCurrentSession();

    	try
    	{
			transaction = session.beginTransaction();
			Query query = session.createQuery("from " + JOB_TABLE + " o where generatedId = :id" +
					" AND status != :canceled");
			query.setString("id", id);
			query.setString("canceled", JobStatus.CANCELED.getStatus());

			job = (Job)query.uniqueResult();

			transaction.commit();
		}
    	catch (HibernateException e)
    	{
    		if(transaction != null) transaction.rollback();
    		throw e;
		}
		return job;
	}
	
	public List<Job> getNotFinishedJobs() throws Exception
	{
		List<Job> jobs = null;
		Transaction transaction = null;
	    Session session 		= InitSessionFactory.getInstance().getCurrentSession();

    	try
    	{
			transaction = session.beginTransaction();
			Query query = session.createQuery("from " + JOB_TABLE + " o where " +
					"o.status != :finished AND " +
					"o.status != :errors AND " +
					"o.status != :canceled");
			
			query.setString("finished", JobStatus.FINISHED.getStatus());
			query.setString("errors", JobStatus.ERRORS.getStatus());
			query.setString("canceled", JobStatus.CANCELED.getStatus());

			jobs = (List<Job>)query.list();

			transaction.commit();
		}
    	catch (HibernateException e)
    	{
    		if(transaction != null) transaction.rollback();
    		throw e;
		}
		return jobs;
	}
	
	public List<Job> getExpiredJobs() throws Exception
	{
		List<Job> jobs = null;
		Transaction transaction = null;
	    Session session 		= InitSessionFactory.getInstance().getCurrentSession();

    	try
    	{
			transaction = session.beginTransaction();
			Query query = session.createQuery("from " + JOB_TABLE + " o where " +
					"o.expirationDate <= NOW() OR " +
					"o.status = :canceled");

			query.setString("canceled", JobStatus.CANCELED.getStatus());

			jobs = (List<Job>)query.list();

			transaction.commit();
		}
    	catch (HibernateException e)
    	{
    		if(transaction != null) transaction.rollback();
    		throw e;
		}
		return jobs;
	}
	
	public void save(Job job) throws Exception
	{
		Transaction transaction = null;
	    Session session 		= InitSessionFactory.getInstance().getCurrentSession();

    	try
    	{
			transaction = session.beginTransaction();
			
			session.save(job);
			
			transaction.commit();
		}
    	catch (HibernateException e)
    	{
    		if(transaction != null) transaction.rollback();
    		throw e;
		}
	}
	
	public void update(Job job) throws Exception
	{
		Transaction transaction = null;
	    Session session 		= InitSessionFactory.getInstance().getCurrentSession();

    	try
    	{
			transaction = session.beginTransaction();
			
			session.update(job);
			
			transaction.commit();
		}
    	catch (HibernateException e)
    	{
    		if(transaction != null) transaction.rollback();
    		throw e;
		}
	}
	
	public void delete(Job job) throws Exception
	{
		Transaction transaction = null;
	    Session session 		= InitSessionFactory.getInstance().getCurrentSession();

    	try
    	{
			transaction = session.beginTransaction();
			
			session.delete(job);
			
			transaction.commit();
		}
    	catch (HibernateException e)
    	{
    		if(transaction != null) transaction.rollback();
    		throw e;
		}
	}

	public void init() throws Exception 
	{
		Transaction transaction = null;
		Session session = InitSessionFactory.getInstance().getCurrentSession();
		
		try
		{
			transaction = session.beginTransaction();
			if(getObjectNumber(session, USER_TABLE) == 0)
			{
				User ud = new User();
				ud.setUsername("admin");
				ud.setPassword(PasswordManager.encrypt("admin"));
				ud.setAdmin(true);
				session.save(ud);
			}
			
			if(getObjectNumber(session, EMAIL_TABLE) == 0)
			{
				EmailNotification params = new EmailNotification();
				session.save(params);
			}
			
			if(getObjectNumber(session, JOB_PARAMS_TABLE) == 0)
			{
				JobParams params = new JobParams();
				session.save(params);
			}
			
			if(getObjectNumber(session, WORKSTATION_TABLE) == 0)
			{
				Workstation params = new Workstation();
				session.save(params);
			}
			
			transaction.commit();
		}
		catch (RuntimeException e)
		{
			if (transaction != null && transaction.isActive())
			{
				try
				{
					transaction.rollback();
				}
				catch(HibernateException e1){}
			}
		}
	}
	
	public List<Job> getJobs(int start, int end,  List<SortConstraint> sortConstraints) throws Exception
	{
		List<Job> jobs = new ArrayList<Job>();
		if(end < start)
		{
			return jobs;
		}
		
		StringBuffer buffer = new StringBuffer("from " + JOB_TABLE + " as o ");
		if(sortConstraints.size() > 0)
		{
			buffer.append(" order by ");
		}
		
		for(SortConstraint c : sortConstraints)
		{
			buffer.append(" o." + c.getPropertyModel().getPropertyName());
			if(c.getColumnSort() == ColumnSort.ASCENDING)
			{
				buffer.append(" asc ");
			}
			else
			{
				buffer.append(" desc ");
			}
		}
		
		Transaction transaction = null;
	    Session session 		= InitSessionFactory.getInstance().getCurrentSession();

    	try
    	{
			transaction = session.beginTransaction();
			Query query = session.createQuery(buffer.toString());
			
			query.setFirstResult(start);
			query.setMaxResults(end - start + 1); 
			
			jobs = (List<Job>)query.list();
			
			transaction.commit();
		}
    	catch (HibernateException e)
    	{
    		if(transaction != null) transaction.rollback();
    		throw e;
		}
		return jobs;
	}
	
	public Long activeJobNumber() throws Exception
	{
		Long size = new Long(0);
		
		Transaction transaction = null;
	    Session session 		= InitSessionFactory.getInstance().getCurrentSession();

    	try
    	{
			transaction = session.beginTransaction();
			
			String queryStr = "select count(*) from " + JOB_TABLE;
			Query query = session.createQuery(queryStr);
			size = (Long)query.uniqueResult();
		}
    	catch (HibernateException e)
    	{
    		if(transaction != null) transaction.rollback();
    		throw e;
		}
		

		return size;
	}
	
	private Long getObjectNumber(Session session, String tableName)
	{
		String queryStr = "select count(*) from " + tableName;
		Query query = session.createQuery(queryStr);
		Long size = (Long)query.uniqueResult();

		return size;
	}
}
