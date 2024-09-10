package PDEXKsvm.enums;

public enum Extensions 
{
	INPUT_FASTA		(".fas"),
	INPUT_PARAMS	(".par"),
	
	LOG_STDOUT		(".log"),
	LOG_STDERR		(".err"),
	
	OUTPUT_COMPARISON_OF_MSA		(".out"),
	OUTPUT_ALIGNED_PDEXK			(".aln"),
	OUTPUT_FINAL_MSA_FASTA			(".fasta"),
	OUTPUT_SVM_PROBABILITY			(".svm");

	private final String extension;
	
	Extensions(String ext)
	{
		this.extension = ext;
	}
	
	public String getExtension()
	{
		return extension;
	}
}

