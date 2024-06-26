﻿<?xml version='1.0' encoding='UTF-8'?>
<Project Type="Project" LVVersion="14008000">
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
		<Item Name="Abstract_Mono.lvclass" Type="LVClass" URL="../Abstract_Mono.lvclass"/>
		<Item Name="Acton.lvclass" Type="LVClass" URL="../../Monochromator_Acton/Acton.lvclass"/>
		<Item Name="Isoplane.lvclass" Type="LVClass" URL="../../Monochromator_Isoplane/Isoplane.lvclass"/>
		<Item Name="Initialized.vi" Type="VI" URL="../../LightField/Initialized.vi"/>
		<Item Name="LightField.ctl" Type="VI" URL="../../LightField/LightField.ctl"/>
		<Item Name="Dependencies" Type="Dependencies">
			<Item Name="vi.lib" Type="Folder">
				<Item Name=".NET Object To Variant.vi" Type="VI" URL="/&lt;vilib&gt;/Platform/dotnet.llb/.NET Object To Variant.vi"/>
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
				<Item Name="NI_XML.lvlib" Type="Library" URL="/&lt;vilib&gt;/xml/NI_XML.lvlib"/>
				<Item Name="Not Found Dialog.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Not Found Dialog.vi"/>
				<Item Name="Search and Replace Pattern.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Search and Replace Pattern.vi"/>
				<Item Name="Set Bold Text.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Set Bold Text.vi"/>
				<Item Name="Set String Value.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Set String Value.vi"/>
				<Item Name="Simple Error Handler.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Simple Error Handler.vi"/>
				<Item Name="TagReturnType.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/TagReturnType.ctl"/>
				<Item Name="Three Button Dialog CORE.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Three Button Dialog CORE.vi"/>
				<Item Name="Three Button Dialog.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Three Button Dialog.vi"/>
				<Item Name="To .NET Object.vi" Type="VI" URL="/&lt;vilib&gt;/Platform/dotnet.llb/To .NET Object.vi"/>
				<Item Name="Trim Whitespace.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Trim Whitespace.vi"/>
				<Item Name="whitespace.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/whitespace.ctl"/>
				<Item Name="subTimeDelay.vi" Type="VI" URL="/&lt;vilib&gt;/express/express execution control/TimeDelayBlock.llb/subTimeDelay.vi"/>
				<Item Name="Error Cluster From Error Code.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Error Cluster From Error Code.vi"/>
				<Item Name="VISA Configure Serial Port" Type="VI" URL="/&lt;vilib&gt;/Instr/_visa.llb/VISA Configure Serial Port"/>
				<Item Name="VISA Configure Serial Port (Instr).vi" Type="VI" URL="/&lt;vilib&gt;/Instr/_visa.llb/VISA Configure Serial Port (Instr).vi"/>
				<Item Name="VISA Configure Serial Port (Serial Instr).vi" Type="VI" URL="/&lt;vilib&gt;/Instr/_visa.llb/VISA Configure Serial Port (Serial Instr).vi"/>
			</Item>
			<Item Name="instr.lib" Type="Folder">
				<Item Name="SP2300i_SEND_ML.vi" Type="VI" URL="/&lt;instrlib&gt;/Acton/Acton/SP2300i_SEND_ML.vi"/>
				<Item Name="SP2300i_GET_EXIT.vi" Type="VI" URL="/&lt;instrlib&gt;/Acton/Acton/SP2300i_GET_EXIT.vi"/>
				<Item Name="SP2300i_GET_GRATING.vi" Type="VI" URL="/&lt;instrlib&gt;/Acton/Acton/SP2300i_GET_GRATING.vi"/>
				<Item Name="SP2300i_GET_SLITWIDTH.vi" Type="VI" URL="/&lt;instrlib&gt;/Acton/Acton/SP2300i_GET_SLITWIDTH.vi"/>
				<Item Name="SP2300i_GET_WL.vi" Type="VI" URL="/&lt;instrlib&gt;/Acton/Acton/SP2300i_GET_WL.vi"/>
				<Item Name="SP2300i_INIT.vi" Type="VI" URL="/&lt;instrlib&gt;/Acton/Acton/SP2300i_INIT.vi"/>
				<Item Name="SP2300i_SET_EXIT.vi" Type="VI" URL="/&lt;instrlib&gt;/Acton/Acton/SP2300i_SET_EXIT.vi"/>
				<Item Name="SP2300i_SET_GRATING.vi" Type="VI" URL="/&lt;instrlib&gt;/Acton/Acton/SP2300i_SET_GRATING.vi"/>
				<Item Name="SP2300i_SET_SLITWIDTH.vi" Type="VI" URL="/&lt;instrlib&gt;/Acton/Acton/SP2300i_SET_SLITWIDTH.vi"/>
				<Item Name="SP2300i_SET_WL.vi" Type="VI" URL="/&lt;instrlib&gt;/Acton/Acton/SP2300i_SET_WL.vi"/>
				<Item Name="SP2300i_GET_GRATINGS.vi" Type="VI" URL="/&lt;instrlib&gt;/Acton/Acton/SP2300i_GET_GRATINGS.vi"/>
			</Item>
			<Item Name="DOMUserDefRef.dll" Type="Document" URL="DOMUserDefRef.dll">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
			<Item Name="LightField Automation.lvclass" Type="LVClass" URL="../../../../IsoPlane/LightField-in-LabVIEW-master/lightfield-automation-labview/LightField Automation.lvclass"/>
			<Item Name="mscorlib" Type="VI" URL="mscorlib">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
			<Item Name="PrincetonInstruments.LightField.AutomationV3.dll" Type="Document" URL="/C/Program Files/Princeton Instruments/LightField/PrincetonInstruments.LightField.AutomationV3.dll"/>
			<Item Name="PrincetonInstruments.LightFieldAddInSupportServices.dll" Type="Document" URL="/C/Program Files/Princeton Instruments/LightField/PrincetonInstruments.LightFieldAddInSupportServices.dll"/>
			<Item Name="PrincetonInstruments.LightFieldViewV3.dll" Type="Document" URL="/C/Program Files/Princeton Instruments/LightField/AddInViews/PrincetonInstruments.LightFieldViewV3.dll"/>
			<Item Name="System" Type="VI" URL="System">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
			<Item Name="FormatGratingString.vi" Type="VI" URL="../../../CCDs/Pylon/FormatGratingString.vi"/>
		</Item>
		<Item Name="Build Specifications" Type="Build"/>
	</Item>
</Project>
