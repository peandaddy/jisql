/*
Only works on on-premise SQL or SQL VM for Windows 

Author: Ji

Version: 1.2
	Add SSIS, SSAS, SSRS info
Version: 2.1
	Add Port info
	Add Windows 2022

Referred to Simond Richards
*/
DECLARE @reg_key VARCHAR(75)
	,@instance VARCHAR(16)
	,@server VARCHAR(55)
	,@SQL_reg_key VARCHAR(150)
	,@Agent_reg_key VARCHAR(150)
	,@SSRS_reg_key VARCHAR(150)
	,@SSAS_reg_key VARCHAR(150)
	,@SSIS_reg_key VARCHAR(150)
	,@SQLBrowser_reg_key VARCHAR(150)
	,@SQLWriter_reg_key VARCHAR(150)
	,@SQLFullText_reg_key VARCHAR(150)
	,@SQLServiceName VARCHAR(50)
	,@AgentServiceName VARCHAR(50)
	,@SSRSServiceName VARCHAR(50)
	,@SSASServiceName VARCHAR(50)
	,@SSISServiceName VARCHAR(50)
	,@SQLBrowserServiceName VARCHAR(50)
	,@SQLWriterServiceName VARCHAR(50)
	,@SQLFullTextServiceName VARCHAR(50)

--Get SQL version Number
DECLARE @xp_msver TABLE (
	[idx] [int] NULL
	,[c_name] [varchar](100) NULL
	,[int_val] [float] NULL
	,[c_val] [varchar](128) NULL
	)
DECLARE @SQLversion SMALLINT

INSERT INTO @xp_msver
EXEC ('[master]..[xp_msver] ''ProductVersion''');;

SELECT @SQLversion = CONVERT(SMALLINT, LEFT([c_val], CHARINDEX('.', [c_val]) - 1))
FROM @xp_msver

DECLARE @Result TABLE (
	[ServerName] SYSNAME NULL
	,[SQLServiceName] VARCHAR(50) NULL
	,[AgentServiceName] VARCHAR(50) NULL
	,[SSRSServiceName] VARCHAR(50) NULL
	,[SSASServiceName] VARCHAR(50) NULL
	,[SSISServiceName] VARCHAR(50) NULL
	,[SQLBrowserServiceName] VARCHAR(50) NULL
	,[SQLWriterServiceName] VARCHAR(50) NULL
	,[SQLFullTextServiceName] VARCHAR(50) NULL
	)

--initalize our key and server name
SET @server = CONVERT(VARCHAR(55), SERVERPROPERTY('ServerName'))
SET @reg_key = 'system\currentcontrolset\services\'; 

--name our services
IF CHARINDEX('\', @server) = 0 --DEFAULT INSTANCE NAME:MSSQLSERVER
BEGIN
	SET @SQLservicename = 'MSSQLSERVER'
	SET @Agentservicename = 'SQLSERVERAGENT'
	SET @SSRSServiceName = 'ReportServer'
	SET @SSASServiceName = 'MSSQLServerOLAPService'
	SET @SQLBrowserServiceName = 'SQLBrowser'
	SET @SQLWriterServiceName = 'SQLWriter'
	SET @SQLFullTextServiceName = 'MSSQLFDLauncher'

	IF @SQLversion = 9
		SET @SSISServiceName = 'MsDtsServer'
	ELSE IF @SQLversion = 10
		SET @SSISServiceName = 'MsDtsServer100'
	ELSE IF @SQLversion = 11
		SET @SSISServiceName = 'MsDtsServer110'
	ELSE IF @SQLversion = 12
		SET @SSISServiceName = 'MsDtsServer120'
	ELSE IF @SQLversion = 13
		SET @SSISServiceName = 'MsDtsServer130' 
	ELSE IF @SQLversion = 14
		SET @SSISServiceName = 'MsDtsServer140' 
	ELSE IF @SQLversion = 15
		SET @SSISServiceName = 'MsDtsServer150' 
	ELSE IF @SQLversion = 16
		SET @SSISServiceName = 'MsDtsServer160' 
			/* For Default Instance SQL Name
		  Any SQL Browser and Writer are the same Reg name: SQLBrowser ,SQLWriter
		  Only Allow One SSIS Service: MsDtsServer (Default 2005), MsDtsServer100 (2008) MsDtsServer110 (DEFAULT SSIS 2012) 

		  MSSQLSERVER
		  SQLSERVERAGENT
		  ReportServer (DEFAULT Instance), 
		  MSSQLServerOLAPService
		  MSSQLFDLauncher   SQL Server full-text search. 
	   */
END
ELSE
BEGIN
	--set the instance name
	SET @instance = RIGHT(@server, LEN(@server) - CHARINDEX('\', @server, 1))
	SET @SQLservicename = 'MSSQL$' + @instance
	SET @Agentservicename = 'SQLAgent$' + @instance
	SET @SSRSServiceName = 'ReportServer$' + @instance
	SET @SSASServiceName = 'MSOLAP$' + @instance
	SET @SQLBrowserServiceName = 'SQLBrowser'
	SET @SQLWriterServiceName = 'SQLWriter'
	SET @SQLFullTextServiceName = 'MSSQLFDLauncher$' + @instance

	IF @SQLversion = 9
		SET @SSISServiceName = 'MsDtsServer'
	ELSE IF @SQLversion = 10
		SET @SSISServiceName = 'MsDtsServer100'
	ELSE IF @SQLversion = 11
		SET @SSISServiceName = 'MsDtsServer110'
	ELSE IF @SQLversion = 12
		SET @SSISServiceName = 'MsDtsServer120'
	ELSE IF @SQLversion = 13
		SET @SSISServiceName = 'MsDtsServer130' 
	ELSE IF @SQLversion = 14
		SET @SSISServiceName = 'MsDtsServer140' 
	ELSE IF @SQLversion = 15
		SET @SSISServiceName = 'MsDtsServer150' 
	ELSE IF @SQLversion = 16
		SET @SSISServiceName = 'MsDtsServer160' 
	/*  For Named SQL Instance Name
	   Any SQL Browser and Writer are the same Reg name: SQLBrowser ,SQLWriter
	   Only Allow One SSIS Service: MsDtsServer (Default 2005), MsDtsServer100 (2008) MsDtsServer110 (DEFAULT SSIS 2012)

	   MSSQL$RUTD
	   SQLAgent$RUTD
	   ReportServer$RUTD (SSRS Instance)
	   MSOLAP$OIMDEV (SSAS Instance)
	   MSSQLFDLauncher$ORAREPLICA (If not installed, the value is null)
    */
END

--initalize the keys
SET @SQL_reg_key = @reg_key + @SQLservicename
SET @Agent_reg_key = @reg_key + @Agentservicename
SET @SSRS_reg_key = @reg_key + @SSRSServiceName
SET @SSAS_reg_key = @reg_key + @SSASServiceName
SET @SSIS_reg_key = @reg_key + @SSISServiceName
SET @SQLBrowser_reg_key = @reg_key + @SQLBrowserServiceName
SET @SQLWriter_reg_key = @reg_key + @SQLWriterServiceName
SET @SQLFullText_reg_key = @reg_key + @SQLFullTextServiceName

--get the SQL account
EXECUTE master..xp_regread 'HKEY_LOCAL_MACHINE'
	,@SQL_reg_key
	,'ObjectName'
	,@SQLservicename OUTPUT
	,'no_output'

--get the Agent account
EXECUTE master..xp_regread 'HKEY_LOCAL_MACHINE'
	,@Agent_reg_key
	,'ObjectName'
	,@Agentservicename OUTPUT
	,'no_output'

EXECUTE master..xp_regread 'HKEY_LOCAL_MACHINE'
	,@SSRS_reg_key
	,'ObjectName'
	,@SSRSServiceName OUTPUT
	,'no_output'

EXECUTE master..xp_regread 'HKEY_LOCAL_MACHINE'
	,@SSAS_reg_key
	,'ObjectName'
	,@SSASServiceName OUTPUT
	,'no_output'

EXECUTE master..xp_regread 'HKEY_LOCAL_MACHINE'
	,@SSIS_reg_key
	,'ObjectName'
	,@SSISServiceName OUTPUT
	,'no_output'

EXECUTE master..xp_regread 'HKEY_LOCAL_MACHINE'
	,@SQLBrowser_reg_key
	,'ObjectName'
	,@SQLBrowserServiceName OUTPUT
	,'no_output'

EXECUTE master..xp_regread 'HKEY_LOCAL_MACHINE'
	,@SQLWriter_reg_key
	,'ObjectName'
	,@SQLWriterServiceName OUTPUT
	,'no_output'

EXECUTE master..xp_regread 'HKEY_LOCAL_MACHINE'
	,@SQLFullText_reg_key
	,'ObjectName'
	,@SQLFullTextServiceName OUTPUT
	,'no_output'

IF @SSRSServiceName = 'ReportServer'
BEGIN
	SET @SSRSServiceName = 'No SSRS'
END
ELSE IF @SSRSServiceName = 'ReportServer$' + @instance
BEGIN
	SET @SSRSServiceName = 'No SSRS'
END

IF @SSASServiceName = 'MSSQLServerOLAPService'
BEGIN
	SET @SSASServiceName = 'No SSAS'
END
ELSE IF @SSASServiceName = 'MSOLAP$' + @instance
BEGIN
	SET @SSASServiceName = 'No SSAS'
END

IF @SSISServiceName = 'MsDtsServer'
BEGIN
	SET @SSISServiceName = 'No SSIS'
END
ELSE IF @SSISServiceName = 'MsDtsServer100'
BEGIN
	SET @SSISServiceName = 'No SSIS'
END
ELSE IF @SSISServiceName = 'MsDtsServer110'
BEGIN
	SET @SSISServiceName = 'No SSIS'
END
ELSE IF @SSISServiceName = 'MsDtsServer120'
BEGIN
	SET @SSISServiceName = 'No SSIS'
END
ELSE IF @SSISServiceName = 'MsDtsServer130'
BEGIN
	SET @SSISServiceName = 'No SSIS' 
END
-- 2022.12.8
ELSE IF @SSISServiceName = 'MsDtsServer140'
BEGIN
	SET @SSISServiceName = 'No SSIS' 
END
ELSE IF @SSISServiceName = 'MsDtsServer150'
BEGIN
	SET @SSISServiceName = 'No SSIS' 
END
ELSE IF @SSISServiceName = 'MsDtsServer160'
BEGIN
	SET @SSISServiceName = 'No SSIS' 
END

IF @SQLBrowserServiceName = 'SQLBrowser'
BEGIN
	SET @SQLBrowserServiceName = 'No SQL Browser'
END

IF @SQLWriterServiceName = 'SQLWriter'
BEGIN
	SET @SQLWriterServiceName = 'No SQL Writer'
END

IF @SQLFullTextServiceName = 'MSSQLFDLauncher'
BEGIN
	SET @SQLFullTextServiceName = 'No SQL Full Text'
END
ELSE IF @SQLFullTextServiceName = 'MSSQLFDLauncher$' + @instance
BEGIN
	SET @SQLFullTextServiceName = 'No SQL Full Text'
END

/*
	  INSERT INTO @Result (
	[ServerName]
	,[SQLServiceName]
	,[AgentServiceName]
	,[SSRSServiceName]
	,[SSASServiceName]
	,[SSISServiceName]
	,[SQLBrowserServiceName]
	,[SQLWriterServiceName]
	,[SQLFullTextServiceName]
	)
SELECT @@SERVERNAME
	,@SQLservicename
	,@Agentservicename
	,@SSRSServiceName
	,@SSASServiceName
	,@SSISServiceName
	,@SQLBrowserServiceName
	,@SQLWriterServiceName
	,@SQLFullTextServiceName;

SELECT * FROM @Result

*/


--=========================================
-- Let's get infomation together
--=========================================
DECLARE @localip NVARCHAR(20)
SELECT @localip = cast(CONNECTIONPROPERTY('local_net_address') AS [nvarchar](20))
-- PRINT @localip

IF @localip is NULL
BEGIN
    SELECT top 1 @localip = cast(local_net_address as [nvarchar](20)) 
	from sys.dm_exec_connections where local_net_address is not NULL
	AND local_net_address <> '::1';

	if @localip is null
	BEGIN
		SET @localip ='TCP could be closed'
	END
END

-- GET opened Port
DECLARE @portNumber NVARCHAR(10),@portNumber2 NVARCHAR(10);
-- GET Domain
DECLARE @Domain varchar(100), @key varchar(100)

IF @@VERSION LIKE '%Linux%'
BEGIN
  SELECT DISTINCT TOP 1 @portNumber = local_tcp_port from sys.dm_exec_connections 
  WHERE local_net_address is not NULL AND local_net_address <> '::1'

  SET @Domain = 'Linux OS'
END
ELSE
BEGIN
	EXEC xp_instance_regread
	    @rootkey = 'HKEY_LOCAL_MACHINE'
	   ,@key = 'Software\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib\Tcp\IpAll'
	   ,@value_name = 'TcpPort'
	   ,@value = @portNumber OUTPUT;
	EXEC xp_instance_regread
	    @rootkey = 'HKEY_LOCAL_MACHINE'
	   ,@key = 'Software\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib\Tcp\IpAll'
	   ,@value_name = 'TcpDynamicPorts'
	   ,@value = @portNumber2 OUTPUT;
	
	-- Get FQDN Domain --
	SET @key = 'SYSTEM\ControlSet001\Services\Tcpip\Parameters\'
	EXEC master..xp_regread @rootkey='HKEY_LOCAL_MACHINE', @key=@key,@value_name='Domain',@value=@Domain OUTPUT
		--select CAST(SERVERPROPERTY('machinename') as varchar(100)) + '.'+@Domain
END

--========================
-- Get Cluster Nodes
--========================
DECLARE @Out NVARCHAR(400)
SELECT @Out = STUFF((
			SELECT ',' + CAST(NodeName AS NVARCHAR(1000))
			FROM sys.dm_os_cluster_nodes t2
			--WHERE t1.NodeName = t2.NodeName
			FOR XML PATh('')
			), 1, 1, '')

--========================
-- Get WindowsVersionBuild
--========================
DECLARE @InHost_distribution nvarchar(256), @InWindows_release nvarchar(256), @Inwindows_sku int;
DECLARE @ParmDefinition NVARCHAR(500); 

DECLARE @SQLProductversion smallint, @SQLString NVARCHAR(4000);
	SELECT @SQLProductversion = CONVERT(smallint, REPLACE(LEFT(  CONVERT(NVARCHAR(2), SERVERPROPERTY('ProductVersion') )  ,2),'.',''))

IF @SQLProductversion <= 13
BEGIN
	SET @SQLString = 'SELECT @OutHost_distribution = windows_release, @OutWindows_release = windows_release, @Outwindows_sku = windows_sku FROM sys.dm_os_windows_info;';

END
ELSE IF @SQLProductversion >= 14
BEGIN
	SET @SQLString = 'SELECT @OutHost_distribution = host_distribution, @OutWindows_release = host_release, @Outwindows_sku = host_sku FROM sys.dm_os_host_info;'

END

SET @ParmDefinition = N'@OutHost_distribution nvarchar(256) OUTPUT, @OutWindows_release nvarchar(256) OUTPUT, @Outwindows_sku int OUTPUT'
EXECUTE sp_executesql @SQLString, @ParmDefinition, @OutHost_distribution = @InHost_distribution OUTPUT, @OutWindows_release = @InWindows_release OUTPUT, @Outwindows_sku = @Inwindows_sku OUTPUT
SELECT @InHost_distribution, @InWindows_release,  @Inwindows_sku

DECLARE @EDITION NVARCHAR(256);
SET @EDITION = 	CASE 
		WHEN @Outwindows_sku = 7 THEN 'Standard'
		WHEN @Outwindows_sku = 8 THEN 'Datacenter'
		ELSE 'Unknown'
SET @OutHost_distribution = CASE

--========================
-- Combine together
--========================
SELECT
	--=====
	COALESCE(
			CASE RIGHT(SUBSTRING(@@VERSION, CHARINDEX('Windows NT', @@VERSION), 14), 3)
				WHEN '5.0' THEN 'Windows 2000'
				WHEN '5.1' THEN 'Windows XP'
				WHEN '5.2' THEN 'Windows Server 2003/2003 R2'
				WHEN '6.0' THEN 'Windows Server 2008/Windows Vista'
				WHEN '6.1' THEN 'Windows Server 2008 R2/Windows 7'
				WHEN '6.2' THEN 'Windows Server 2012/Windows 8'
				WHEN '6.3' THEN 'Windows Server 2012R2/Windows 8.1'
				WHEN '10.0' THEN 'Windows Server 2016/Windowds 10'
			END
			,
	   	   CASE RIGHT(SUBSTRING(@@VERSION, CHARINDEX('Windows Server', @@VERSION), 19), 4)
	 			WHEN '2012' THEN 'Windows Server 2012/Windows 8'
	 			WHEN '2008' THEN 'Windows Server 2008 R2/Windows 7'
	 			WHEN '2012' THEN 'Windows Server 2012R2/Windows 8.1'
	 		    WHEN '2016' THEN 'Windows Server 2016/Windowds 10/11'
				WHEN '2019' THEN 'Windows Server 2019/Windowds 10/11'
				WHEN '2022' THEN 'Windows Server 2022/Windowds 11'
	 			ELSE 'Windows Server 2016+'
	 	   END 		   ,
			CASE 
				WHEN RIGHT(SUBSTRING(@@VERSION, CHARINDEX('Linux', @@VERSION), 35), 3) LIKE '%Ubuntu%' THEN 'Linux Ubuntu'
				WHEN RIGHT(SUBSTRING(@@VERSION, CHARINDEX('Linux', @@VERSION), 35), 3) LIKE '%RedHat%' THEN 'Linux RedHat'
				ELSE 'Linux OS'
			END
		)  AS [WindowsVersionBuild]
	,  SERVERPROPERTY('ComputerNamePhysicalNetBIOS') as [CurrentRunningNode]
	,
		CASE SERVERPROPERTY('IsClustered') 
			WHEN 0 THEN 'False'
			WHEN 1 THEN 'True'
		END AS [Is Clustered]
	,
		@Out AS [ClusterNodes]
	,
	   DEFAULT_DOMAIN() AS [DomainPrefix]
	 , CAST(SERVERPROPERTY('machinename') as varchar(100)) + '.'+ @Domain AS [FQDN]
	 , @@SERVICENAME AS [InstanceName]
     ,CASE
		 WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('ProductVersion')) like '8%' THEN 'Microsoft SQL Server 2000'
		 WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('ProductVersion')) like '9%' THEN 'Microsoft SQL Server 2005'
		 WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('ProductVersion')) like '10.0%' THEN 'Microsoft SQL Server 2008'
		 WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('ProductVersion')) like '10.5%' THEN 'Microsoft SQL Server 2008 R2'
		 WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('ProductVersion')) like '11%' THEN 'Microsoft SQL Server 2012'
		 WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('ProductVersion')) like '12%' THEN 'Microsoft SQL Server 2014'
		 WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('ProductVersion')) like '13%' THEN 'Microsoft SQL Server 2016'  
		 WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('ProductVersion')) like '14%' THEN 'Microsoft SQL Server 2017'
		 WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('ProductVersion')) like '15%' THEN 'Microsoft SQL Server 2019'
		 WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('ProductVersion')) like '16%' THEN 'Microsoft SQL Server 2022'		 
		 ELSE 'unknown'
	  END AS [Version]
	, SERVERPROPERTY('Edition') AS [SQLEdition] 
    , SERVERPROPERTY ('ProductLevel') AS [ProductLevel] 
    , SERVERPROPERTY('ProductVersion') AS [ProductVersion]
	, SERVERPROPERTY('ProductUpdateLevel') AS [SQLCU] 
	, SERVERPROPERTY('ProductUpdateReference') AS [UpdateRefernce]	
    , @localip AS [local_net_address] --SQL 2008+
    , REPLACE(@portNumber,',',';') AS [StaticListeningPort] 
    , REPLACE(@portNumber2,',',';') AS [DynamicListeningPort]
    , CASE 
		WHEN CHARINDEX('Hypervisor', @@VERSION) > 1	THEN 'Virtual Machine'
		ELSE 'Physical Machine'
	 END [Machine Type]

	-- (optional) From Service account section
	 , @SQLservicename AS [SQLServiceName], @Agentservicename AS [AgentServiceName], @SSRSServiceName AS [SSRSServiceName],@SSASServiceName AS [SSASServiceName],@SSISServiceName AS [SSISServiceName],@SQLBrowserServiceName AS [SQLBrowserServiceName],@SQLWriterServiceName AS [SQLWriterServiceName],@SQLFullTextServiceName [SQLFullTextServiceName]
 ;
