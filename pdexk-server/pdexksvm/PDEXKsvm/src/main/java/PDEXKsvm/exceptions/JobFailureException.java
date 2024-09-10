package PDEXKsvm.exceptions;

public class JobFailureException extends Exception
{
	private static final long serialVersionUID = 1L;

	public JobFailureException(String msg)
	{
		super(msg);
	}
}
