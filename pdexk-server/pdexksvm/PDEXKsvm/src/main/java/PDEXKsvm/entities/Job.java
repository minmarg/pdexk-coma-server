package PDEXKsvm.entities;

import java.util.Date;
import java.util.HashSet;
import java.util.Set;

import org.apache.tapestry5.beaneditor.NonVisual;

import PDEXKsvm.dataManagement.JobStatus;

public class Job 
{
	@NonVisual
	private long	id;
	@NonVisual
	private String 	generatedId;
	@NonVisual
	private String 	workstationId;
	
	private String 	email;
	private String 	status = JobStatus.SUBMITTED.getStatus();
	private String 	type;

	private String 	description;
	
	@NonVisual
	private Date 	submissionDate;
	private Date 	expirationDate;
	
	@NonVisual
	private String error;
	@NonVisual
	private Set<ClassificationObject> classificationObjects;
	@NonVisual
	private Set<DataFile> dataFiles;
	@NonVisual
	private int numberofSeq = 0;
	
	@NonVisual
	public String getShortName()
	{
		if(getDescription() != null)
		{
			if(getDescription().length() > 15)
			{
				return getDescription().substring(0, 15) + "...";
			}
			return getDescription();
		}
		
		if(getGeneratedId().length() > 15)
		{
			return getGeneratedId().substring(0, 15) + "...";
		}
		return getGeneratedId();
	}
	
	public long getId() {
		return id;
	}
	public void setId(long id) {
		this.id = id;
	}
	public String getGeneratedId() {
		return generatedId;
	}
	public void setGeneratedId(String generatedId) {
		this.generatedId = generatedId;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public String getWorkstationId() {
		return workstationId;
	}
	public void setWorkstationId(String workstationId) {
		this.workstationId = workstationId;
	}
	public Date getSubmissionDate() {
		return submissionDate;
	}
	public void setSubmissionDate(Date submissionDate) {
		this.submissionDate = submissionDate;
	}
	public Date getExpirationDate() {
		return expirationDate;
	}
	public void setExpirationDate(Date expirationDate) {
		this.expirationDate = expirationDate;
	}
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	public Set<DataFile> getDataFiles() 
	{
		if(dataFiles == null)
		{
			dataFiles = new HashSet<DataFile>();
		}
		return dataFiles;
	}
	public void setDataFiles(Set<DataFile> dataFiles) {
		this.dataFiles = dataFiles;
	}

	public String getError() {
		return error;
	}

	public void setError(String error) {
		this.error = error;
	}

	public Set<ClassificationObject> getClassificationObjects() {
		return classificationObjects;
	}

	public void setClassificationObjects(
			Set<ClassificationObject> classificationObjects) {
		this.classificationObjects = classificationObjects;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public int getNumberofSeq() {
		return numberofSeq;
	}

	public void setNumberofSeq(int numberofSeq) {
		this.numberofSeq = numberofSeq;
	}
}
