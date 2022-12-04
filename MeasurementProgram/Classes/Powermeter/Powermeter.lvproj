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
		<Item Name="Abstract_Powermeter.lvclass" Type="LVClass" URL="/&lt;instrlib&gt;/Classes/Powermeter/Abstract/Abstract_Powermeter.lvclass"/>
		<Item Name="TestPowermeter.vi" Type="VI" URL="/&lt;instrlib&gt;/Classes/Powermeter/Thorlabs_PM100D/TestPowermeter.vi"/>
		<Item Name="Thorlabs_PM100D.lvclass" Type="LVClass" URL="/&lt;instrlib&gt;/Classes/Powermeter/Thorlabs_PM100D/Thorlabs_PM100D.lvclass"/>
		<Item Name="TLPM Get Average Time.vi" Type="VI" URL="/&lt;instrlib&gt;/TLPM/TLPM.llb/TLPM Get Average Time.vi"/>
		<Item Name="Dependencies" Type="Dependencies">
			<Item Name="instr.lib" Type="Folder">
				<Item Name="TLPM Set Average Time.vi" Type="VI" URL="/&lt;instrlib&gt;/TLPM/TLPM.llb/TLPM Set Average Time.vi"/>
			</Item>
			<Item Name="TLPM Close.vi" Type="VI" URL="../../../../../../../Program Files (x86)/Thorlabs/PowerMeters/LabView/LabView 64 bit/TLPM/TLPM.llb/TLPM Close.vi"/>
			<Item Name="TLPM Find Resources.vi" Type="VI" URL="../../../../../../../Program Files (x86)/Thorlabs/PowerMeters/LabView/LabView 64 bit/TLPM/TLPM.llb/TLPM Find Resources.vi"/>
			<Item Name="TLPM Get Resource Name.vi" Type="VI" URL="../../../../../../../Program Files (x86)/Thorlabs/PowerMeters/LabView/LabView 64 bit/TLPM/TLPM.llb/TLPM Get Resource Name.vi"/>
			<Item Name="TLPM Get Wavelength.vi" Type="VI" URL="../../../../../../../Program Files (x86)/Thorlabs/PowerMeters/LabView/LabView 64 bit/TLPM/TLPM.llb/TLPM Get Wavelength.vi"/>
			<Item Name="TLPM Initialize.vi" Type="VI" URL="../../../../../../../Program Files (x86)/Thorlabs/PowerMeters/LabView/LabView 64 bit/TLPM/TLPM.llb/TLPM Initialize.vi"/>
			<Item Name="TLPM Measure Power.vi" Type="VI" URL="../../../../../../../Program Files (x86)/Thorlabs/PowerMeters/LabView/LabView 64 bit/TLPM/TLPM.llb/TLPM Measure Power.vi"/>
			<Item Name="TLPM Set Wavelength.vi" Type="VI" URL="../../../../../../../Program Files (x86)/Thorlabs/PowerMeters/LabView/LabView 64 bit/TLPM/TLPM.llb/TLPM Set Wavelength.vi"/>
			<Item Name="TLPM VXIpnp Error Converter.vi" Type="VI" URL="../../../../../../../Program Files (x86)/Thorlabs/PowerMeters/LabView/LabView 64 bit/TLPM/TLPM.llb/TLPM VXIpnp Error Converter.vi"/>
			<Item Name="TLPM_64.dll" Type="Document" URL="TLPM_64.dll">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
		</Item>
		<Item Name="Build Specifications" Type="Build"/>
	</Item>
</Project>
