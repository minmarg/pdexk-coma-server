package bioinfo.comaWebServer.comparators;

/* 	$Date: 2009-12-23 15:29:07 +0200 (Wed, 23 Dec 2009) $
 	$Author: Mindaugas.Laganeckas $
	$Revision: 26 $
	$HeadURL: https://comawebserver.googlecode.com/svn/branches/testing/src/main/java/bioinfo/comaWebServer/comparators/ResultsAlignmentComparator.java $
	$Id: ResultsAlignmentComparator.java 26 2009-12-23 13:29:07Z Mindaugas.Laganeckas $
*/
import java.util.Comparator;

import bioinfo.comaWebServer.entities.ResultsAlignment;

public class ResultsAlignmentComparator implements Comparator<ResultsAlignment> 
{
	public int compare(ResultsAlignment a, ResultsAlignment b) 
	{
		if(a.getPriority() > b.getPriority())
		{
			return 1;
		}
		if(a.getPriority() < b.getPriority())
		{
			return -1;
		}
		return 0;
	}

}
