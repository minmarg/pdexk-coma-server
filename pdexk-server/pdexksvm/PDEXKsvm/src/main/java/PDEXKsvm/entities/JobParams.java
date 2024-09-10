package PDEXKsvm.entities;

public class JobParams 
{
	private long id;
	private int expirationPeriod = 10;
	private int expirationPeriodErr = 5;
	private int maxSubmittedJobs = 500;
	private double pdexkProbability = 0.8;
	private int numberOfSequencesInFinalMSA = 3;
	private String urlForResults;
	
	public long getId() {
		return id;
	}
	public void setId(long id) {
		this.id = id;
	}
	public int getExpirationPeriod() {
		return expirationPeriod;
	}
	public void setExpirationPeriod(int expirationPeriod) {
		this.expirationPeriod = expirationPeriod;
	}
	public int getExpirationPeriodErr() {
		return expirationPeriodErr;
	}
	public void setExpirationPeriodErr(int expirationPeriodErr) {
		this.expirationPeriodErr = expirationPeriodErr;
	}
	public String getUrlForResults() {
		return urlForResults;
	}
	public void setUrlForResults(String urlForResults) {
		this.urlForResults = urlForResults;
	}
	public int getMaxSubmittedJobs() {
		return maxSubmittedJobs;
	}
	public void setMaxSubmittedJobs(int maxSubmittedJobs) {
		this.maxSubmittedJobs = maxSubmittedJobs;
	}
	public double getPdexkProbability() {
		return pdexkProbability;
	}
	public void setPdexkProbability(double pdexkProbability) {
		this.pdexkProbability = pdexkProbability;
	}
	public int getNumberOfSequencesInFinalMSA() {
		return numberOfSequencesInFinalMSA;
	}
	public void setNumberOfSequencesInFinalMSA(int numberOfSequencesInFinalMSA) {
		this.numberOfSequencesInFinalMSA = numberOfSequencesInFinalMSA;
	}
}
