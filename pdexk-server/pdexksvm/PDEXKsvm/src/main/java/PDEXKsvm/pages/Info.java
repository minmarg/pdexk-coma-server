package PDEXKsvm.pages;

public class Info 
{
	private String info;
	
	void onActivate(String msg)
	{
		info = msg;
	}
	
	String onPassivate()
	{
		return info;
	}

	public String getInfo() {
		return info;
	}

	public void setInfo(String info) {
		this.info = info;
	}
	
}
