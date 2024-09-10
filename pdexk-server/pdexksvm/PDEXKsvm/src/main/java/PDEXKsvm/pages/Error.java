package PDEXKsvm.pages;

public class Error 
{
	private String error;
	
	void onActivate(String msg)
	{
		error = msg;
	}
	
	String onPassivate()
	{
		return error;
	}

	public String getError() {
		return error;
	}

	public void setError(String error) {
		this.error = error;
	}

}
