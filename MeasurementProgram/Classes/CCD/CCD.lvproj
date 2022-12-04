<?xml version='1.0' encoding='UTF-8'?>
<Project Type="Project" LVVersion="20008000">
	<Item Name="My Computer" Type="My Computer">
		<Property Name="NI.SortType" Type="Int">3</Property>
		<Property Name="server.app.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.control.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.tcp.enabled" Type="Bool">false</Property>
		<Property Name="server.tcp.port" Type="Int">0</Property>
		<Property Name="server.tcp.serviceName" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.tcp.serviceName.default" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.vi.callsEnabled" Type="Bool">true</Property>
		<Property Name="server.vi.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="specify.custom.address" Type="Bool">false</Property>
		<Item Name="00_SpectrometerTest.vi" Type="VI" URL="/&lt;instrlib&gt;/Classes/CCD/Avantes/00_SpectrometerTest.vi"/>
		<Item Name="Abstract_CCD.lvclass" Type="LVClass" URL="/&lt;instrlib&gt;/Classes/CCD/Abstract_CCD/Abstract_CCD.lvclass"/>
		<Item Name="Avantes.lvclass" Type="LVClass" URL="/&lt;instrlib&gt;/Classes/CCD/Avantes/Avantes.lvclass"/>
		<Item Name="ADCQuality.ctl" Type="VI" URL="/&lt;instrlib&gt;/Classes/CCD/Abstract_CCD/ADCQuality.ctl"/>
		<Item Name="FanMode.ctl" Type="VI" URL="/&lt;instrlib&gt;/Classes/CCD/Abstract_CCD/FanMode.ctl"/>
		<Item Name="FrameCombination.ctl" Type="VI" URL="/&lt;instrlib&gt;/Classes/CCD/Abstract_CCD/FrameCombination.ctl"/>
		<Item Name="DeviceQueue_Action.ctl" Type="VI" URL="../../../../../../../Users/Timo/Desktop/SpinCoater/TypDef/DeviceQueue_Action.ctl"/>
		<Item Name="DataQueue_TypeDef.ctl" Type="VI" URL="../../../../../../../Users/Timo/Desktop/SpinCoater/TypDef/DataQueue_TypeDef.ctl"/>
		<Item Name="DataQueue_Action.ctl" Type="VI" URL="../../../../../../../Users/Timo/Desktop/SpinCoater/TypDef/DataQueue_Action.ctl"/>
		<Item Name="Dependencies" Type="Dependencies">
			<Item Name="instr.lib" Type="Folder">
				<Item Name="Abstract_Mono.lvclass" Type="LVClass" URL="/&lt;instrlib&gt;/Classes/Monochromator/Monochromator_Abstract/Abstract_Mono.lvclass"/>
				<Item Name="AVS_Activate.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_Activate.vi"/>
				<Item Name="AVS_Deactivate.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_Deactivate.vi"/>
				<Item Name="AVS_Done.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_Done.vi"/>
				<Item Name="AVS_GetLambda.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_GetLambda.vi"/>
				<Item Name="AVS_GetList.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_GetList.vi"/>
				<Item Name="AVS_GetNrOfDevices.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_GetNrOfDevices.vi"/>
				<Item Name="AVS_GetParameter.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_GetParameter.vi"/>
				<Item Name="AVS_GetScopeData.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_GetScopeData.vi"/>
				<Item Name="AVS_Init.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_Init.vi"/>
				<Item Name="AVS_Measure.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_Measure.vi"/>
				<Item Name="AVS_PollScan.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_PollScan.vi"/>
				<Item Name="AVS_PrepareMeasure.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_PrepareMeasure.vi"/>
				<Item Name="AVS_SetParameter.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_SetParameter.vi"/>
				<Item Name="AVS_StopMeasure.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_StopMeasure.vi"/>
				<Item Name="AVS_UseHighResADC.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_UseHighResADC.vi"/>
				<Item Name="Byte_to_DeviceConfigType.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/Byte_to_DeviceConfigType.vi"/>
				<Item Name="clusterdef.ctl" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/clusterdef.ctl"/>
				<Item Name="DeviceConfigType_to_Byte.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/DeviceConfigType_to_Byte.vi"/>
				<Item Name="Find_Spectrometer.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/Find_Spectrometer.vi"/>
				<Item Name="AVS_GetNumPixels.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_GetNumPixels.vi"/>
			</Item>
			<Item Name="avaspecx64.dll" Type="Document" URL="../../../../../../../AvaSpecX64-DLL_9.4/avaspecx64.dll"/>
		</Item>
		<Item Name="Build Specifications" Type="Build"/>
	</Item>
</Project>
