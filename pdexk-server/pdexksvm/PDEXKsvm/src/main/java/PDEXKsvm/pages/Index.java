package PDEXKsvm.pages;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import org.apache.tapestry5.SelectModel;
import org.apache.tapestry5.annotations.Component;
import org.apache.tapestry5.annotations.InjectPage;
import org.apache.tapestry5.annotations.OnEvent;
import org.apache.tapestry5.annotations.Persist;
import org.apache.tapestry5.annotations.Property;
import org.apache.tapestry5.annotations.SessionState;
import org.apache.tapestry5.corelib.components.Form;
import org.apache.tapestry5.corelib.components.Select;
import org.apache.tapestry5.corelib.components.TextArea;
import org.apache.tapestry5.ioc.Messages;
import org.apache.tapestry5.ioc.annotations.Inject;
import org.apache.tapestry5.services.Cookies;
import org.apache.tapestry5.upload.services.UploadedFile;
import org.apache.tapestry5.util.EnumSelectModel;

import util.CookieManager;
import util.Validator;

import PDEXKsvm.entities.Job;
import PDEXKsvm.entities.RecentJobs;
import PDEXKsvm.enums.InputType;
import PDEXKsvm.enums.SearchStrategy;
import PDEXKsvm.services.JobSubmitter;


/**
 * Start page of application PDEXKsvm.
 */
public class Index
{
	@Property
	@Component
	private Form submitJobForm;
	@Property
	@Component(id = "sequence")
	private TextArea txtAreaSeq;
	@Property
	@Component(id = "inputType")
	private Select selectInputType;
	@Property
	@SessionState
    private RecentJobs recentJobs;
	@Property
	@Persist
	private UploadedFile file;
	@Property
	@Persist
	private PDEXKsvm.enums.InputType type;
	@Property
	@Persist
	private String email;
	@Property
	@Persist
	private String sequence;
	@Property
	@Persist
	private String description;
	
	@Property
	@Persist
	private SearchStrategy searchStrategy;
	public SearchStrategy getNoPsiBlast()
	{
		return SearchStrategy.NO_PSI_BLAST;
	}
	public SearchStrategy getServerHandle()
	{
		return SearchStrategy.SERVER_HANDLE;
	}
	
	private boolean reset;
	@OnEvent(component="resetButton", value = "selected")
	void onResetButton()
	{
		reset = true;
		setInit(false);
	}
	
	@Inject
	private Messages messages;
	public SelectModel getTypes()
	{
		return new EnumSelectModel(InputType.class, messages);
	}
	
	@Persist
	private boolean init;
	
	public void onPrepare() throws Exception
	{
		if(!init)
		{
			init 			= true;
			type 			= InputType.FASTA;
			file 			= null;
			email 			= null;
			sequence 		= null;
			description 	= null;
			searchStrategy 	= SearchStrategy.SERVER_HANDLE;
		}
	}

	private void setInit(boolean init) {
		this.init = init;
	}
	
	@InjectPage
	private Wait wait;
	
	Object onSuccess()
	{	
		if(reset)
		{
			reset = false;
			return null;
		}
		
		if(file == null && sequence == null)
		{
			submitJobForm.recordError(txtAreaSeq, "You must specify an input source!");
			return null;
		}
		
		List<String> lines = null;
		
		try 
		{
			lines = input2list(sequence, file);
		} 
		catch (IOException e1) 
		{
			e1.printStackTrace();
			submitJobForm.recordError(txtAreaSeq, "File upload failed! Try to paste Your sequence or multiple alignment!");
			return null;
		}

		try 
		{
			boolean goodFormat = Validator.check(lines, type);
			if(!goodFormat)
			{
				submitJobForm.recordError(selectInputType, "Incorrect input format!");
				return null;
			}
		} 
		catch (Exception e) 
		{
			submitJobForm.recordError(selectInputType, e.getMessage());
			return null;
		}
		
		Job job = null;
		
		try 
		{
			job = JobSubmitter.submit(lines, description, email, type, searchStrategy);
		} 
		catch (Exception e) 
		{
			submitJobForm.recordError(selectInputType, e.getMessage());
			return null;
		}
		
		setInit(false);
		
		recentJobs.addJob(job);
		
		CookieManager.registerJob(job.getGeneratedId(), cookies);
		
		wait.init(job.getGeneratedId());
		
		return wait;
	}
	
	private static List<String> input2list(String sequence, UploadedFile file) throws IOException
	{
		List<String> lines = new ArrayList<String>();
		
		if(sequence != null)
		{
			String[] data = sequence.split("\n");
			for(int i = 0; i < data.length; i++)
			{
				lines.add(data[i].replaceAll("\\s+$", ""));
			}
		}
		else
		{
			BufferedReader input = new BufferedReader(new InputStreamReader(file.getStream()));
			String line = null;

			while((line = input.readLine()) != null)
			{
				lines.add(line);
			}
		}
		
		return lines;
	}
	
	
	@Inject
    private Cookies cookies;

}
