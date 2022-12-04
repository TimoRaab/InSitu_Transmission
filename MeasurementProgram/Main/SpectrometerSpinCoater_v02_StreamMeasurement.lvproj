<?xml version='1.0' encoding='UTF-8'?>
<Project Type="Project" LVVersion="18008000">
	<Item Name="My Computer" Type="My Computer">
		<Property Name="server.app.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.control.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.tcp.enabled" Type="Bool">false</Property>
		<Property Name="server.tcp.port" Type="Int">0</Property>
		<Property Name="server.tcp.serviceName" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.tcp.serviceName.default" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.vi.callsEnabled" Type="Bool">true</Property>
		<Property Name="server.vi.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="specify.custom.address" Type="Bool">false</Property>
		<Item Name="SpectrometerSpinCoater_v02_StreamMeasurement.vi" Type="VI" URL="../SpectrometerSpinCoater_v02_StreamMeasurement.vi"/>
		<Item Name="Dependencies" Type="Dependencies"/>
		<Item Name="Build Specifications" Type="Build">
			<Item Name="SpectrometerSpinCoater_v02_StreamMeasurement" Type="EXE">
				<Property Name="App_copyErrors" Type="Bool">true</Property>
				<Property Name="App_INI_aliasGUID" Type="Str">{A1BDE314-F3E7-4642-9B93-A592E15CE131}</Property>
				<Property Name="App_INI_GUID" Type="Str">{963E0F61-529E-47D5-9E0D-622FE0EE5FA6}</Property>
				<Property Name="App_serverConfig.httpPort" Type="Int">8002</Property>
				<Property Name="Bld_autoIncrement" Type="Bool">true</Property>
				<Property Name="Bld_buildCacheID" Type="Str">{C84A7423-95B6-40EA-8E58-CAA40F18E622}</Property>
				<Property Name="Bld_buildSpecName" Type="Str">SpectrometerSpinCoater_v02_StreamMeasurement</Property>
				<Property Name="Bld_excludeInlineSubVIs" Type="Bool">true</Property>
				<Property Name="Bld_excludeLibraryItems" Type="Bool">true</Property>
				<Property Name="Bld_excludePolymorphicVIs" Type="Bool">true</Property>
				<Property Name="Bld_localDestDir" Type="Path">../builds/NI_AB_PROJECTNAME/SpectrometerSpinCoater_v02_StreamMeasurement</Property>
				<Property Name="Bld_localDestDirType" Type="Str">relativeToCommon</Property>
				<Property Name="Bld_modifyLibraryFile" Type="Bool">true</Property>
				<Property Name="Bld_previewCacheID" Type="Str">{7FFAD86A-09F0-4998-A7E7-5BDE9E18432C}</Property>
				<Property Name="Bld_version.major" Type="Int">1</Property>
				<Property Name="Destination[0].destName" Type="Str">Application.exe</Property>
				<Property Name="Destination[0].path" Type="Path">../builds/NI_AB_PROJECTNAME/SpectrometerSpinCoater_v02_StreamMeasurement/Application.exe</Property>
				<Property Name="Destination[0].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[0].type" Type="Str">App</Property>
				<Property Name="Destination[1].destName" Type="Str">Support Directory</Property>
				<Property Name="Destination[1].path" Type="Path">../builds/NI_AB_PROJECTNAME/SpectrometerSpinCoater_v02_StreamMeasurement/data</Property>
				<Property Name="DestinationCount" Type="Int">2</Property>
				<Property Name="Source[0].itemID" Type="Str">{67BCFCBD-E3D9-4674-B75C-4F06FC95A151}</Property>
				<Property Name="Source[0].type" Type="Str">Container</Property>
				<Property Name="Source[1].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[1].itemID" Type="Ref">/My Computer/SpectrometerSpinCoater_v02_StreamMeasurement.vi</Property>
				<Property Name="Source[1].sourceInclusion" Type="Str">TopLevel</Property>
				<Property Name="Source[1].type" Type="Str">VI</Property>
				<Property Name="SourceCount" Type="Int">2</Property>
				<Property Name="TgtF_companyName" Type="Str">Universität Konstanz</Property>
				<Property Name="TgtF_fileDescription" Type="Str">SpectrometerSpinCoater_v02_StreamMeasurement</Property>
				<Property Name="TgtF_internalName" Type="Str">SpectrometerSpinCoater_v02_StreamMeasurement</Property>
				<Property Name="TgtF_legalCopyright" Type="Str">Copyright © 2018 Universität Konstanz</Property>
				<Property Name="TgtF_productName" Type="Str">SpectrometerSpinCoater_v02_StreamMeasurement</Property>
				<Property Name="TgtF_targetfileGUID" Type="Str">{303D8121-5DE6-406C-BC14-A601385ED4E3}</Property>
				<Property Name="TgtF_targetfileName" Type="Str">Application.exe</Property>
				<Property Name="TgtF_versionIndependent" Type="Bool">true</Property>
			</Item>
		</Item>
	</Item>
</Project>
