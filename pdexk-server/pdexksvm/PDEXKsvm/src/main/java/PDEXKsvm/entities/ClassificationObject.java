package PDEXKsvm.entities;

public class ClassificationObject 
{
	private long id;
	private String trainingAccuracy;
	private String predictedProbability;
	
	public long getId() {
		return id;
	}
	public void setId(long id) {
		this.id = id;
	}
	public String getTrainingAccuracy() {
		return trainingAccuracy;
	}
	public void setTrainingAccuracy(String trainingAccuracy) {
		this.trainingAccuracy = trainingAccuracy;
	}
	public String getPredictedProbability() {
		return predictedProbability;
	}
	public void setPredictedProbability(String predictedProbability) {
		this.predictedProbability = predictedProbability;
	}

}
