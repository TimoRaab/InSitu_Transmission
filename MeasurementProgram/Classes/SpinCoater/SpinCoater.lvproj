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
		<Item Name="SpectrometerSpinCoater_v07.vi" Type="VI" URL="../../../../../../MeasurementPrograms/SpinCoater/SpectrometerSpinCoater_v07.vi"/>
		<Item Name="SpectrometerSpinCoater_v10.vi" Type="VI" URL="../../../../../../MeasurementPrograms/SpinCoater/SpectrometerSpinCoater_v10.vi"/>
		<Item Name="SpinCoater.lvclass" Type="LVClass" URL="/&lt;instrlib&gt;/Classes/SpinCoater/SpinCoater.lvclass"/>
		<Item Name="SpinProgramCheck.vi" Type="VI" URL="/&lt;instrlib&gt;/Classes/SpinCoater/Examples/SpinProgramCheck.vi"/>
		<Item Name="Dependencies" Type="Dependencies">
			<Item Name="instr.lib" Type="Folder">
				<Item Name="Abstract_CCD.lvclass" Type="LVClass" URL="/&lt;instrlib&gt;/Classes/CCD/Abstract_CCD/Abstract_CCD.lvclass"/>
				<Item Name="Abstract_Mono.lvclass" Type="LVClass" URL="/&lt;instrlib&gt;/Classes/Monochromator/Monochromator_Abstract/Abstract_Mono.lvclass"/>
				<Item Name="ADCQuality.ctl" Type="VI" URL="/&lt;instrlib&gt;/Classes/CCD/Abstract_CCD/ADCQuality.ctl"/>
				<Item Name="Avantes.lvclass" Type="LVClass" URL="/&lt;instrlib&gt;/Classes/CCD/Avantes/Avantes.lvclass"/>
				<Item Name="AVS_Activate.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_Activate.vi"/>
				<Item Name="AVS_Deactivate.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_Deactivate.vi"/>
				<Item Name="AVS_Done.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_Done.vi"/>
				<Item Name="AVS_GetLambda.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_GetLambda.vi"/>
				<Item Name="AVS_GetList.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_GetList.vi"/>
				<Item Name="AVS_GetNrOfDevices.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_GetNrOfDevices.vi"/>
				<Item Name="AVS_GetNumPixels.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/AVS_GetNumPixels.vi"/>
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
				<Item Name="FanMode.ctl" Type="VI" URL="/&lt;instrlib&gt;/Classes/CCD/Abstract_CCD/FanMode.ctl"/>
				<Item Name="Find_Spectrometer.vi" Type="VI" URL="/&lt;instrlib&gt;/Devices/Avantes/Find_Spectrometer.vi"/>
				<Item Name="FrameCombination.ctl" Type="VI" URL="/&lt;instrlib&gt;/Classes/CCD/Abstract_CCD/FrameCombination.ctl"/>
			</Item>
			<Item Name="vi.lib" Type="Folder">
				<Item Name="BuildHelpPath.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/BuildHelpPath.vi"/>
				<Item Name="Check Special Tags.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Check Special Tags.vi"/>
				<Item Name="Clear Errors.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Clear Errors.vi"/>
				<Item Name="Convert property node font to graphics font.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Convert property node font to graphics font.vi"/>
				<Item Name="Details Display Dialog.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Details Display Dialog.vi"/>
				<Item Name="DialogType.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/DialogType.ctl"/>
				<Item Name="DialogTypeEnum.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/DialogTypeEnum.ctl"/>
				<Item Name="Error Code Database.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Error Code Database.vi"/>
				<Item Name="ErrWarn.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/ErrWarn.ctl"/>
				<Item Name="eventvkey.ctl" Type="VI" URL="/&lt;vilib&gt;/event_ctls.llb/eventvkey.ctl"/>
				<Item Name="Find Tag.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Find Tag.vi"/>
				<Item Name="Format Message String.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Format Message String.vi"/>
				<Item Name="General Error Handler Core CORE.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/General Error Handler Core CORE.vi"/>
				<Item Name="General Error Handler.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/General Error Handler.vi"/>
				<Item Name="Get String Text Bounds.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Get String Text Bounds.vi"/>
				<Item Name="Get Text Rect.vi" Type="VI" URL="/&lt;vilib&gt;/picture/picture.llb/Get Text Rect.vi"/>
				<Item Name="GetHelpDir.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/GetHelpDir.vi"/>
				<Item Name="GetRTHostConnectedProp.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/GetRTHostConnectedProp.vi"/>
				<Item Name="Longest Line Length in Pixels.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Longest Line Length in Pixels.vi"/>
				<Item Name="LVBoundsTypeDef.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/miscctls.llb/LVBoundsTypeDef.ctl"/>
				<Item Name="LVRectTypeDef.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/miscctls.llb/LVRectTypeDef.ctl"/>
				<Item Name="NI_AALBase.lvlib" Type="Library" URL="/&lt;vilib&gt;/Analysis/NI_AALBase.lvlib"/>
				<Item Name="NI_Matrix.lvlib" Type="Library" URL="/&lt;vilib&gt;/Analysis/Matrix/NI_Matrix.lvlib"/>
				<Item Name="Not Found Dialog.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Not Found Dialog.vi"/>
				<Item Name="Search and Replace Pattern.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Search and Replace Pattern.vi"/>
				<Item Name="Set Bold Text.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Set Bold Text.vi"/>
				<Item Name="Set String Value.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Set String Value.vi"/>
				<Item Name="subTimeDelay.vi" Type="VI" URL="/&lt;vilib&gt;/express/express execution control/TimeDelayBlock.llb/subTimeDelay.vi"/>
				<Item Name="TagReturnType.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/TagReturnType.ctl"/>
				<Item Name="Three Button Dialog CORE.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Three Button Dialog CORE.vi"/>
				<Item Name="Three Button Dialog.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Three Button Dialog.vi"/>
				<Item Name="Trim Whitespace.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Trim Whitespace.vi"/>
				<Item Name="VISA Configure Serial Port" Type="VI" URL="/&lt;vilib&gt;/Instr/_visa.llb/VISA Configure Serial Port"/>
				<Item Name="VISA Configure Serial Port (Instr).vi" Type="VI" URL="/&lt;vilib&gt;/Instr/_visa.llb/VISA Configure Serial Port (Instr).vi"/>
				<Item Name="VISA Configure Serial Port (Serial Instr).vi" Type="VI" URL="/&lt;vilib&gt;/Instr/_visa.llb/VISA Configure Serial Port (Serial Instr).vi"/>
				<Item Name="whitespace.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/whitespace.ctl"/>
			</Item>
			<Item Name="AfterSpinOptions.vi" Type="VI" URL="../../../../../../MeasurementPrograms/SpinCoater/VI/AfterSpinOptions.vi"/>
			<Item Name="avaspecx64.dll" Type="Document" URL="../../../../../../AvaSpecX64-DLL_9.4/avaspecx64.dll"/>
			<Item Name="CalculateFrames_v02.vi" Type="VI" URL="../../../../../../MeasurementPrograms/SpinCoater/VI/CalculateFrames_v02.vi"/>
			<Item Name="DataQueue_Action.ctl" Type="VI" URL="../../../../../../MeasurementPrograms/SpinCoater/TypDef/DataQueue_Action.ctl"/>
			<Item Name="DataQueue_TypeDef.ctl" Type="VI" URL="../../../../../../MeasurementPrograms/SpinCoater/TypDef/DataQueue_TypeDef.ctl"/>
			<Item Name="DeviceInfo2Str.vi" Type="VI" URL="../../../../../../MeasurementPrograms/SpinCoater/VI/DeviceInfo2Str.vi"/>
			<Item Name="DeviceQueue_Action.ctl" Type="VI" URL="../../../../../../MeasurementPrograms/SpinCoater/TypDef/DeviceQueue_Action.ctl"/>
			<Item Name="DeviceQueue_TypeDef.ctl" Type="VI" URL="../../../../../../MeasurementPrograms/SpinCoater/TypDef/DeviceQueue_TypeDef.ctl"/>
			<Item Name="lvanlys.dll" Type="Document" URL="/&lt;resource&gt;/lvanlys.dll"/>
			<Item Name="MeasurementSpin2String.vi" Type="VI" URL="../../../../../../MeasurementPrograms/SpinCoater/VI/MeasurementSpin2String.vi"/>
			<Item Name="Num2Str_TrailingZero.vi" Type="VI" URL="../../../../../../MeasurementPrograms/SpinCoater/VI/Num2Str_TrailingZero.vi"/>
			<Item Name="String_SpectralStabilitySettings.vi" Type="VI" URL="../../../../../../MeasurementPrograms/SpinCoater/VI/String_SpectralStabilitySettings.vi"/>
			<Item Name="TabControl.ctl" Type="VI" URL="../../../../../../MeasurementPrograms/SpinCoater/TypDef/TabControl.ctl"/>
		</Item>
		<Item Name="Build Specifications" Type="Build"/>
	</Item>
</Project>
