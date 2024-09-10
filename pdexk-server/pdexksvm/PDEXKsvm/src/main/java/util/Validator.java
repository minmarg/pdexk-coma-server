package util;

import java.util.ArrayList;
import java.util.List;

import PDEXKsvm.enums.InputType;

public class Validator 
{
	
	public static boolean check(List<String> lines, InputType format) throws Exception
	{
		if(format == InputType.FASTA)
		{
			return checkFasta(lines);
		}
		else
		{
			throw new Exception("Unknown input format: " + format);
		}
	}
	
	private static boolean checkFasta(List<String> lines)
	{
		if(lines.size() == 0)
		{
			return false;
		}
		
		String fastaHeader  = "^>\\w+.*";
		String fastaData = "[ABCDEFGHIKLMNOPQRSTUVWYZXabcdefghiklmnopqrstuvwyzx*\\-\\s]+";	
		
		List<String> fasta = new ArrayList<String>();
		for(int i = 0; i < lines.size();)
		{
			String line = lines.get(i);
			if(line.matches(fastaHeader))
			{
				fasta.add(line);
				i++;
			}
			else
			{
				StringBuffer buffer = new StringBuffer();
				for(; i < lines.size() && !lines.get(i).matches(fastaHeader); i++)
				{
					buffer.append(lines.get(i));
				}
				fasta.add(buffer.toString());
			}
		}
		
		if(fasta.size() % 2 != 0)
		{
			return false;
		}
		
		int lineLength = fasta.get(1).length();
		
		for(int i = 0; i < fasta.size();)
		{
			String header = fasta.get(i);
			if(!header.matches(fastaHeader))
			{
				return false;
			}
			
			String data = fasta.get(i + 1);
			if(data.length() != lineLength)
			{
				return false;
			}
			if(!data.matches(fastaData))
			{
				return false;	
			}
			
			i += 2;
		}

		return true;
	}
}
