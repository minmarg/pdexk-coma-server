package PDEXKsvm.enums;

public enum JobType 
{
	PDEXK	("PDEXK");

	private final String type;
	
	JobType(String type)
	{
		this.type = type;
	}

	public String getType() {
		return type;
	}

}
