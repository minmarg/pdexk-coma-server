package PDEXKsvm.services;

import java.util.List;

import org.apache.tapestry5.grid.SortConstraint;

import PDEXKsvm.entities.EmailNotification;
import PDEXKsvm.entities.Job;
import PDEXKsvm.entities.JobParams;
import PDEXKsvm.entities.User;
import PDEXKsvm.entities.Workstation;

public interface IDataSource 
{
	public void init() throws Exception;
	
	public Long activeJobNumber() throws Exception;
	
	public User getUser(String username, String password) throws Exception;
	public void update(User user) throws Exception; 
	
	public EmailNotification getEmailParams() throws Exception;
	public void update(EmailNotification params) throws Exception; 
	
	public JobParams getJobParams() throws Exception;
	public void update(JobParams params) throws Exception;
	
	public Workstation getWorkstation() throws Exception;
	public void update(Workstation params) throws Exception;
	
	public Job getJob(String id) throws Exception;
	public List<Job> getNotFinishedJobs() throws Exception;
	public List<Job> getExpiredJobs() throws Exception;
	public void save(Job job) throws Exception;
	public void update(Job job) throws Exception;
	public void delete(Job job) throws Exception;
	public List<Job> getJobs(int start, int end,  List<SortConstraint> sortConstraints) throws Exception;
}
