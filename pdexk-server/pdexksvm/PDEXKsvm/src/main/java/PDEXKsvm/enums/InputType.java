package PDEXKsvm.enums;

public enum InputType 
{
	FASTA	("fasta", ".fas");

	private final String extension;
	private final String name;
	
	InputType(String name, String ext)
	{
		this.extension = ext;
		this.name = name;
	}
	
	public String getExtension()
	{
		return extension;
	}

	public String getName() {
		return name;
	}
}
