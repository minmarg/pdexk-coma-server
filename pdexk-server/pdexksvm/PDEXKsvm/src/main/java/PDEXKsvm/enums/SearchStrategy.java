package PDEXKsvm.enums;

public enum SearchStrategy 
{
	NO_PSI_BLAST	("NO_PSI_BLAST"), //do not use psi-blast
	SERVER_HANDLE 	("SERVER_HANDLE"); //let the server handle

	private final String value;
	
	SearchStrategy(String val)
	{
		this.value = val;
	}
	
	public String getValue()
	{
		return value;
	}
}
