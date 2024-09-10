package PDEXKsvm.entities;

public class Workstation 
{
	private long id;
	private String hostname;
	private String username;
	private String keyFilePath;
	private String keyfilePass = "";
	private String remoteFilePath;
	private String globalFilePath;
	private String localFilePath;
	private String scriptPath;
	private boolean local;
	
	public long getId() {
		return id;
	}
	public void setId(long id) {
		this.id = id;
	}
	public String getHostname() {
		return hostname;
	}
	public void setHostname(String hostname) {
		this.hostname = hostname;
	}
	public String getUsername() {
		return username;
	}
	public void setUsername(String username) {
		this.username = username;
	}
	public String getKeyFilePath() {
		return keyFilePath;
	}
	public void setKeyFilePath(String keyFilePath) {
		this.keyFilePath = keyFilePath;
	}
	public String getKeyfilePass() {
		return keyfilePass;
	}
	public void setKeyfilePass(String keyfilePass) {
		this.keyfilePass = keyfilePass;
	}
	public boolean isLocal() {
		return local;
	}
	public void setLocal(boolean local) {
		this.local = local;
	}
	public String getRemoteFilePath() 
	{
		return remoteFilePath;
	}
	public void setRemoteFilePath(String remoteFilePath) {
		this.remoteFilePath = remoteFilePath;
	}
	public String getGlobalFilePath() 
	{
		return globalFilePath;
	}
	public void setGlobalFilePath(String globalFilePath) {
		this.globalFilePath = globalFilePath;
	}
	public String getLocalFilePath()
	{
		return localFilePath;
	}
	public void setLocalFilePath(String localFilePath) {
		this.localFilePath = localFilePath;
	}
	public String getScriptPath() {
		return scriptPath;
	}
	public void setScriptPath(String scriptPath) {
		this.scriptPath = scriptPath;
	}
}
