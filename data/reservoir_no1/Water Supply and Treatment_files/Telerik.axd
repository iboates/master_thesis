/* START Telerik.Sitefinity.Modules.Forms.Web.UI.Scripts.FormsControl.js */
Type.registerNamespace("Telerik.Sitefinity.Modules.Forms.Web.UI");
Telerik.Sitefinity.Modules.Forms.Web.UI.FormsControl=function(element){Telerik.Sitefinity.Modules.Forms.Web.UI.FormsControl.initializeBase(this,[element]);
this._handlePageLoadDelegate=null;
this._formFieldsMetadata=null;
this._formSubmitButtonsMetadata=null;
this._usePostbackOnSubmit=null;
this._formsSubmitUrl=null;
this._successMessage=null;
this._successMessageBlockId=null;
this._formControlsContainerId=null;
this._formDescriptionFound=null;
this._formId=null;
this._formName=null;
this._formRedirectUrl=null;
this._formSubmitAction=null;
this._errorsPanelContainerId=null;
this._hasFileUploadField=null;
this._validationGroup=null;
this._clrTypeDelimiter=null;
this._successMessageAfterFormUpdate=null;
this._submitActionAfterFormUpdate=null;
this._redirectPageUrlAfterFormUpdate=null;
this._currentMode=null;
this._formEditContext=null;
this._formsQueryDataElement=null;
};
Telerik.Sitefinity.Modules.Forms.Web.UI.FormsControl.prototype={initialize:function(){Telerik.Sitefinity.Modules.Forms.Web.UI.FormsControl.callBaseMethod(this,"initialize");
this._handlePageLoadDelegate=Function.createDelegate(this,this._handlePageLoad);
Sys.Application.add_load(this._handlePageLoadDelegate);
},dispose:function(){Telerik.Sitefinity.Modules.Forms.Web.UI.FormsControl.callBaseMethod(this,"dispose");
if(this._handlePageLoadDelegate){Sys.Application.remove_load(this._handlePageLoadDelegate);
delete this._handlePageLoadDelegate;
}},_handlePageLoad:function(){var fieldsMetadata=JSON.parse(this.get_formFieldsMetadata());
var formSubmitButtonsMetadata=JSON.parse(this.get_formSubmitButtonsMetadata());
var oldBrowsers=false;
if(!window.FormData||!window.XMLHttpRequest){oldBrowsers=true;
}var that=this;
$.each(formSubmitButtonsMetadata,function(i,button){$("#"+button.Id).on("click",function(e){if(oldBrowsers||that.get_usePostbackOnSubmit()){return Telerik.Sitefinity.Web.UI.Fields.FormManager.validateGroup(that.get_validationGroup());
}e.preventDefault();
var formData=new FormData();
var isInputValid=Telerik.Sitefinity.Web.UI.Fields.FormManager.validateGroup(that.get_validationGroup());
if(isInputValid){$.each(fieldsMetadata,function(i,field){var fieldControl=$find(field.Id);
if(!fieldControl){return;
}var fieldValue=fieldControl.get_value();
if(typeof(fieldControl.get_radUpload)==="function"&&fieldControl.get_radUpload()){$.each(fieldControl.get_radUpload().getFileInputs(),function(i,uploadControl){$.each(uploadControl.files,function(i,file){formData.append(field.FieldName,file,file.name);
});
});
}else{if(field.ClrType){var serializeData=Sys.Serialization.JavaScriptSerializer.serialize(fieldValue);
formData.append(field.FieldName,serializeData+that._clrTypeDelimiter+field.ClrType);
}else{formData.append(field.FieldName,fieldValue);
}}});
var spinner=$("#loadingPanel_"+button.Id.split("_").pop());
var xhr=new XMLHttpRequest();
var url=String.format(that.get_formsSubmitUrl()+"/?name={0}&formId={1}&currentMode={2}",that.get_formName(),that.get_formId(),that._currentMode);
var editContext=that.get_formEditContext();
if(editContext&&editContext.IsValidUpdateRequest){url=String.format(url+"&data={0}",editContext.QueryData);
formData.append("_formsQueryDataElement",that.get_formsQueryDataElement().value);
}xhr.open("POST",url,true);
xhr.onload=function(){spinner.hide();
$("#"+button.Id).attr("disabled",false);
if(xhr.status===200){that.processFormSubmitAction();
}else{if(xhr.status===409){}else{var responseJson=JSON.parse(xhr.response);
if($("#"+that.get_errorsPanelContainerId()).length>0){$("#"+that.get_errorsPanelContainerId()).text(responseJson.error);
$("#"+that.get_errorsPanelContainerId()).show();
}}}};
$("#"+button.Id).attr("disabled",true);
spinner.show();
xhr.send(formData);
}});
});
},processFormSubmitAction:function(){var submitAction=this._getSubmitAction();
var pageUrl=this._getSubmitPageUrl();
var successMessage=this._getSubmitSuccessMessage();
switch(submitAction){case"PageRedirect":if(pageUrl!=null){window.location.replace(pageUrl);
}break;
case"TextMessage":if(successMessage!=null){$("#"+this.get_formControlsContainerId()).hide();
$("#"+this.get_successMessageBlockId()).text(successMessage);
$("#"+this.get_successMessageBlockId()).show();
}break;
default:throw new Error("Not implemented form submit action - "+submitAction);
}},_getSubmitAction:function(){return this.get_isInEditMode()?this._submitActionAfterFormUpdate:this.get_formSubmitAction();
},_getSubmitSuccessMessage:function(){return this.get_isInEditMode()?this._successMessageAfterFormUpdate:this.get_successMessage();
},_getSubmitPageUrl:function(){return this.get_isInEditMode()?this._redirectPageUrlAfterFormUpdate:this.get_formRedirectUrl();
},get_validationGroup:function(){return this._validationGroup;
},set_validationGroup:function(value){this._validationGroup=value;
},get_hasFileUploadField:function(){return this._hasFileUploadField;
},set_hasFileUploadField:function(value){this._hasFileUploadField=value;
},get_errorsPanelContainerId:function(){return this._errorsPanelContainerId;
},set_errorsPanelContainerId:function(value){this._errorsPanelContainerId=value;
},get_formRedirectUrl:function(){return this._formRedirectUrl;
},set_formRedirectUrl:function(value){this._formRedirectUrl=value;
},get_formSubmitAction:function(){return this._formSubmitAction;
},set_formSubmitAction:function(value){this._formSubmitAction=value;
},get_formId:function(){return this._formId;
},set_formId:function(value){this._formId=value;
},get_formName:function(){return this._formName;
},set_formName:function(value){this._formName=value;
},get_formDescriptionFound:function(){return this._formDescriptionFound;
},set_formDescriptionFound:function(value){this._formDescriptionFound=value;
},get_successMessage:function(){return this._successMessage;
},set_successMessage:function(value){this._successMessage=value;
},get_successMessageBlockId:function(){return this._successMessageBlockId;
},set_successMessageBlockId:function(value){this._successMessageBlockId=value;
},get_formControlsContainerId:function(){return this._formControlsContainerId;
},set_formControlsContainerId:function(value){this._formControlsContainerId=value;
},get_formFieldsMetadata:function(){return this._formFieldsMetadata;
},set_formFieldsMetadata:function(value){this._formFieldsMetadata=value;
},get_formSubmitButtonsMetadata:function(){return this._formSubmitButtonsMetadata;
},set_formSubmitButtonsMetadata:function(value){this._formSubmitButtonsMetadata=value;
},get_usePostbackOnSubmit:function(){return this._usePostbackOnSubmit;
},set_usePostbackOnSubmit:function(value){this._usePostbackOnSubmit=value;
},get_formsSubmitUrl:function(){return this._formsSubmitUrl;
},set_formsSubmitUrl:function(value){this._formsSubmitUrl=value;
},get_isInEditMode:function(){var editContext=this.get_formEditContext();
if(editContext){return editContext.IsValidUpdateRequest;
}return false;
},get_formEditContext:function(){if(this._formEditContext){return JSON.parse(this._formEditContext);
}return null;
},get_formsQueryDataElement:function(){return this._formsQueryDataElement;
},set_formsQueryDataElement:function(value){this._formsQueryDataElement=value;
},};
Telerik.Sitefinity.Modules.Forms.Web.UI.FormsControl.registerClass("Telerik.Sitefinity.Modules.Forms.Web.UI.FormsControl",Sys.UI.Control);
if(typeof(Sys)!=="undefined"){Sys.Application.notifyScriptLoaded();
}
/* END Telerik.Sitefinity.Modules.Forms.Web.UI.Scripts.FormsControl.js */
/* START Telerik.Sitefinity.Web.UI.Fields.Scripts.FormManagerEventArgs.js */
Type.registerNamespace("Telerik.Sitefinity.Web.UI.Fields");
Telerik.Sitefinity.Web.UI.Fields.FormFieldValidationEventArgs=function(fieldControl,validationGroup){this._fieldControl=fieldControl;
this._validated=false;
this._isValid=true;
this._validationGroup=validationGroup;
Telerik.Sitefinity.Web.UI.Fields.FormFieldValidationEventArgs.initializeBase(this);
};
Telerik.Sitefinity.Web.UI.Fields.FormFieldValidationEventArgs.prototype={initialize:function(){Telerik.Sitefinity.Web.UI.Fields.FormFieldValidationEventArgs.callBaseMethod(this,"initialize");
},dispose:function(){Telerik.Sitefinity.Web.UI.Fields.FormFieldValidationEventArgs.callBaseMethod(this,"dispose");
},get_fieldControl:function(){return this._fieldControl;
},set_fieldControl:function(value){this._fieldControl=value;
},get_isValid:function(){return this._isValid;
},set_isValid:function(value){this._isValid=value;
},get_validated:function(){return this._validated;
},set_validated:function(value){this._validated=value;
},get_validationGroup:function(){return this._validationGroup;
},set_validationGroup:function(value){this._validationGroup=value;
}};
Telerik.Sitefinity.Web.UI.Fields.FormFieldValidationEventArgs.registerClass("Telerik.Sitefinity.Web.UI.Fields.FormFieldValidationEventArgs",Sys.EventArgs);
Telerik.Sitefinity.Web.UI.Fields.ValidationCompletedEventArgs=function(violationMessages,validationGroup,validationResult){Telerik.Sitefinity.Web.UI.Fields.ValidationCompletedEventArgs.initializeBase(this);
this._validationGroup=validationGroup;
this._violationMessages=violationMessages;
this._validationResult=validationResult;
};
Telerik.Sitefinity.Web.UI.Fields.ValidationCompletedEventArgs.prototype={initialize:function(){Telerik.Sitefinity.Web.UI.Fields.ValidationCompletedEventArgs.callBaseMethod(this,"initialize");
},dispose:function(){Telerik.Sitefinity.Web.UI.Fields.ValidationCompletedEventArgs.callBaseMethod(this,"dispose");
},get_validationGroup:function(){return this._validationGroup;
},set_validationGroup:function(value){this._validationGroup=value;
},get_violationMessages:function(){return this._violationMessages;
},set_violationMessages:function(value){this._violationMessages=value;
},get_validationResult:function(){return this._validationResult;
}};
Telerik.Sitefinity.Web.UI.Fields.ValidationCompletedEventArgs.registerClass("Telerik.Sitefinity.Web.UI.Fields.ValidationCompletedEventArgs",Sys.EventArgs);

/* END Telerik.Sitefinity.Web.UI.Fields.Scripts.FormManagerEventArgs.js */
/* START Telerik.Sitefinity.Web.UI.Fields.Scripts.FormManager.js */
Type.registerNamespace("Telerik.Sitefinity.Web.UI.Fields");
var $get_clientId;
if(typeof($FormManager)==="undefined"){var $FormManager=null;
}Telerik.Sitefinity.Web.UI.Fields.FormManager=function(){Telerik.Sitefinity.Web.UI.Fields.FormManager.initializeBase(this);
this._controlIdMappings={};
this._validationGroupMappings={};
};
Telerik.Sitefinity.Web.UI.Fields.FormManager.IsRegistered=false;
Telerik.Sitefinity.Web.UI.Fields.FormManager.prototype={initialize:function(){Telerik.Sitefinity.Web.UI.Fields.FormManager.callBaseMethod(this,"initialize");
if(Telerik.Sitefinity.Web.UI.Fields.FormManager.IsRegistered){return;
}Telerik.Sitefinity.Web.UI.Fields.FormManager._controlIdMappings=this._controlIdMappings;
Telerik.Sitefinity.Web.UI.Fields.FormManager.getControlId=$get_clientId=this.getControlId;
Telerik.Sitefinity.Web.UI.Fields.FormManager._validationGroupMappings=this._validationGroupMappings;
Telerik.Sitefinity.Web.UI.Fields.FormManager.validateGroup=this.validateGroup;
Telerik.Sitefinity.Web.UI.Fields.FormManager.validateAll=this.validateAll;
$FormManager=this;
Telerik.Sitefinity.Web.UI.Fields.FormManager.IsRegistered=true;
},dispose:function(){Telerik.Sitefinity.Web.UI.Fields.FormManager.callBaseMethod(this,"dispose");
},getControlId:function(serverId){var controlId=$FormManager._controlIdMappings[serverId];
if(!controlId){alert('This form expects a control with ID "'+serverId+'" to be present and may not work properly as it is missing. You may see this message, because the corresponding default field was removed.');
controlId=null;
}return controlId;
},validateGroup:function(validationGroup){if(validationGroup===undefined||validationGroup==null){validationGroup="";
}var clientIDs=$FormManager._validationGroupMappings[validationGroup];
var result=true;
var violationMessages=[];
if(clientIDs){var iter=clientIDs.length;
while(iter--){var fieldControl=$find(clientIDs[iter]);
var resultArgs=$FormManager._raiseFieldValidation(fieldControl,validationGroup);
var isValid;
if(resultArgs&&typeof(resultArgs.get_validated)==="function"&&typeof(resultArgs.get_isValid)==="function"){if(resultArgs.get_validated()){isValid=resultArgs.get_isValid();
}}else{isValid=fieldControl.validate();
}if(!isValid){var msgs=fieldControl.get_violationMessages();
var count=msgs.length;
while(count--){violationMessages.push(msgs[count]);
}result=false;
}}}$FormManager._raiseFormValidationCompleted(violationMessages,validationGroup,result);
return result;
},validateAll:function(){var result=true;
var mappings=this._validationGroupMappings;
for(var group in mappings){var isValid=this.validateGroup(group);
if(!isValid){result=false;
}}return result;
},add_onFieldValidation:function(delegate){this.get_events().addHandler("onFieldValidation",delegate);
},remove_onFieldValidation:function(delegate){this.get_events().removeHandler("onFieldValidation",delegate);
},add_onFormValidationCompleted:function(delegate){this.get_events().addHandler("onFormValidationCompleted",delegate);
},remove_onFormValidationCompleted:function(delegate){this.get_events().removeHandler("onFormValidationCompleted",delegate);
},_raiseFieldValidation:function(fieldControl,validationGroup){var eventArgs=new Telerik.Sitefinity.Web.UI.Fields.FormFieldValidationEventArgs(fieldControl,validationGroup);
var h=this.get_events().getHandler("onFieldValidation");
if(h){h(this,eventArgs);
}},_raiseFormValidationCompleted:function(violationMessages,validationGroup,validationResult){var eventArgs=new Telerik.Sitefinity.Web.UI.Fields.ValidationCompletedEventArgs(violationMessages,validationGroup,validationResult);
var h=this.get_events().getHandler("onFormValidationCompleted");
if(h){h(this,eventArgs);
}}};
Telerik.Sitefinity.Web.UI.Fields.FormManager.registerClass("Telerik.Sitefinity.Web.UI.Fields.FormManager",Sys.Component);

/* END Telerik.Sitefinity.Web.UI.Fields.Scripts.FormManager.js */
/* START Telerik.Sitefinity.Web.UI.Fields.Scripts.IField.js */
Type.registerNamespace("Telerik.Sitefinity.Web.UI.Fields");
Telerik.Sitefinity.Web.UI.Fields.IField=function(){};
Telerik.Sitefinity.Web.UI.Fields.IField.prototype={get_title:function(){},set_title:function(value){},get_example:function(){},set_example:function(value){},get_description:function(){},set_description:function(value){},get_titleElement:function(){},set_titleElement:function(value){},get_exampleElement:function(){},set_exampleElement:function(value){},get_descriptionElement:function(){},set_descriptionElement:function(value){}};
Telerik.Sitefinity.Web.UI.Fields.IField.registerInterface("Telerik.Sitefinity.Web.UI.Fields.IField");

/* END Telerik.Sitefinity.Web.UI.Fields.Scripts.IField.js */
/* START Telerik.Sitefinity.Web.UI.Validation.Scripts.Validator.js */
Type.registerNamespace("Telerik.Sitefinity.Web.UI.Validation");
Telerik.Sitefinity.Web.UI.Validation.Validator=function(validatorDefinition){this._expectedFormat=null;
this._maxLength=null;
this._minLength=null;
this._maxValue=null;
this._minValue=null;
this._regularExpression=null;
this._required=null;
this._alphaNumericViolationMessage=null;
this._currencyViolationMessage=null;
this._emailAddressViolationMessage=null;
this._integerViolationMessage=null;
this._internetUrlViolationMessage=null;
this._maxLengthViolationMessage=null;
this._maxValueViolationMessage=null;
this._messageCssClass=null;
this._messageTagName=null;
this._minLengthViolationMessage=null;
this._minValueViolationMessage=null;
this._nonAlphaNumericViolationMessage=null;
this._numericViolationMessage=null;
this._percentageViolationMessage=null;
this._regularExpressionViolationMessage=null;
this._requiredViolationMessage=null;
this._uSocialSecurityNumberViolationMessage=null;
this._uSZipCodeViolationMessage=null;
this._validateIfInvisible=null;
this._comparingValidatorDefinitions=null;
this._regularExpressionSeparator=null;
this._violationMessages=[];
this._violationMessageElement=null;
this._validatorDefinition=validatorDefinition;
this.alphaNumericRegexPattern=/[-_a-zA-Z0-9]+$/;
this.currencyRegexPattern=/[+-]?[0-9]{1,3}(?:[0-9]*(?:[.,][0-9]{2})?|(?:,[0-9]{3})*(?:\.[0-9]{2})?|(?:\.[0-9]{3})*(?:,[0-9]{2})?)/;
this.emailAddressRegexPattern=/^[a-zA-Z0-9._%+-]+@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,4}$/i;
this.integerRegexPattern=/^[-+]?\d+$/;
this.internetUrlRegexPattern=/(?:(?:https?|ftp|file):\/\/|www\.|ftp\.)[-A-Za-z0-9+&@#\/%=~_|$?!:,.]*[A-Za-z0-9+&@#\/%=~_|$]/;
this.nonAlphaNumericRegexPattern=/[^-_a-zA-Z0-9]+/;
this.numericRegexPattern=/^[-+]?[0-9]+((,|\.)[0-9]+)?/;
this.percentRegexPattern=/100$|^\s*(\d{0,2})((\.|\,)(\d*))?\s*\%?\s*/;
this.uSSocialSecurityRegexPattern=/(?!000)(?!666)(?:[0-6]\d{2}|7(?:[0-356]\d|7[012]))[- ](?!00)\d{2}[- ](?!0000)\d{4}/;
this.uSZipCodeRegexPattern=/[0-9]{5}(?:-[0-9]{4})?/;
this._violationMessageElementWasCreated=false;
Telerik.Sitefinity.Web.UI.Validation.Validator.initializeBase(this);
this.initialize();
};
Telerik.Sitefinity.Web.UI.Validation.Validator.prototype={initialize:function(){this.configure(this._validatorDefinition);
delete this._validatorDefinition;
Telerik.Sitefinity.Web.UI.Validation.Validator.callBaseMethod(this,"initialize");
},dispose:function(){Telerik.Sitefinity.Web.UI.Validation.Validator.callBaseMethod(this,"dispose");
},validate:function(value){var isValid=true;
this.set_violationMessages([]);
var validatingArgs=this._onValidatingHandler(value);
isValid=validatingArgs.get_isValid();
if(!validatingArgs.get_cancel()){isValid=this._evaluateIsValid(value);
}this._onValidatedHandler(isValid,value);
return isValid;
},configure:function(definition){for(var validatorDefPropertyName in definition){this._setPropertyIfChanged(validatorDefPropertyName,definition[validatorDefPropertyName]);
}},add_onValidating:function(delegate){this.get_events().addHandler("onValidating",delegate);
},remove_onValidating:function(delegate){this.get_events().removeHandler("onValidating",delegate);
},add_onValidated:function(delegate){this.get_events().addHandler("onValidated",delegate);
},remove_onValidated:function(delegate){this.get_events().removeHandler("onValidated",delegate);
},_onValidatingHandler:function(value){var eventArgs=new Telerik.Sitefinity.Web.UI.Validation.ValidatingEventArgs(value);
var h=this.get_events().getHandler("onValidating");
if(h){h(this,eventArgs);
}return eventArgs;
},_onValidatedHandler:function(isValid,value){var eventArgs=new Telerik.Sitefinity.Web.UI.Validation.ValidatedEventArgs(isValid,value);
var h=this.get_events().getHandler("onValidated");
if(h){h(this,eventArgs);
}return eventArgs;
},_evaluateIsValid:function(value){if(typeof value===typeof""){value=value.trim();
}if(this._validateRequired(value)){var isValid=true;
isValid=this._validateRange(value)&&isValid;
isValid=this._validateRegex(value)&&isValid;
isValid=this._validateComparisons(value)&&isValid;
return isValid;
}return false;
},_validateRequired:function(value){if(this.get_required()){if(!value||value===""||value===false){this.get_violationMessages().push(this.get_requiredViolationMessage());
return false;
}else{if(Array.prototype.isPrototypeOf(value)){if(value.length==0){this.get_violationMessages().push(this.get_requiredViolationMessage());
return false;
}}}}return true;
},_validateRange:function(value){if(value!==null&&value!==undefined){if(!isNaN(value)&&(this.get_minValue()!=null||this.get_maxValue()!=null)){return this._validateNumericDateRange(value);
}if(String.isInstanceOfType(value)||(typeof value)===(typeof"")){return this._validateStringRange(value);
}if(!isNaN(value)&&Array.isInstanceOfType(value)){return this._validateArrayRange(value);
}}return true;
},_validateStringRange:function(value){if(this.get_minLength()>0){var isMinLengthValid=value.length>=this.get_minLength();
if(!isMinLengthValid){this.get_violationMessages().push(this.get_minLengthViolationMessage());
return false;
}}if(this.get_maxLength()>0){var isMaxLengthValid=value.length<=this.get_maxLength();
if(!isMaxLengthValid){this.get_violationMessages().push(this.get_maxLengthViolationMessage());
return false;
}}return true;
},_validateNumericDateRange:function(value){if(this.get_minValue()!=null){var isMinValueValid=value>=this.get_minValue();
if(!isMinValueValid){this.get_violationMessages().push(this.get_minValueViolationMessage());
return false;
}}if(this.get_maxValue()!=null){var isMaxValueValid=value<=this.get_maxValue();
if(!isMaxValueValid){this.get_violationMessages().push(this.get_maxValueViolationMessage());
return false;
}}return true;
},_validateArrayRange:function(value){if(value.length||value.length===0){var isMaxLengthValid=true;
var isMinLengthValid=true;
if(this.get_maxLength()>0){isMaxLengthValid=this.get_maxLength()<=value.length;
}if(this.get_minLength()>0){isMinLengthValid=this.get_minLength()>=value.length;
}if(isMinLengthValid&&isMaxLengthValid){return true;
}this.get_violationMessages().push(this.get_maxLengthViolationMessage());
return false;
}return false;
},_validateRegex:function(value){if(String.isInstanceOfType(value)||(typeof value)===(typeof"")){return this._validateStringRegex(value);
}return true;
},_validateStringRegex:function(value){var regex=this.get_regularExpression();
if(regex){return this._validateCustomRegex(value,regex);
}var expectedFormat=this.get_expectedFormat();
if(expectedFormat>0){return this._validateExpectedFormat(value,expectedFormat);
}return true;
},_validateExpectedFormat:function(value,expectedFormat){var isValid=true;
switch(expectedFormat){case Telerik.Sitefinity.Web.UI.Validation.Enums.ValidationFormat.None:return true;
case Telerik.Sitefinity.Web.UI.Validation.Enums.ValidationFormat.AlphaNumeric:isValid=this.alphaNumericRegexPattern.test(value);
if(!isValid){this.get_violationMessages().push(this.get_alphaNumericViolationMessage());
}break;
case Telerik.Sitefinity.Web.UI.Validation.Enums.ValidationFormat.Currency:isValid=this.currencyRegexPattern.test(value);
if(!isValid){this.get_violationMessages().push(this.get_currencyViolationMessage());
}break;
case Telerik.Sitefinity.Web.UI.Validation.Enums.ValidationFormat.EmailAddress:isValid=this.emailAddressRegexPattern.test(value);
if(!isValid){this.get_violationMessages().push(this.get_emailAddressViolationMessage());
}break;
case Telerik.Sitefinity.Web.UI.Validation.Enums.ValidationFormat.Integer:isValid=this.integerRegexPattern.test(value);
if(!isValid){this.get_violationMessages().push(this.get_integerViolationMessage());
}break;
case Telerik.Sitefinity.Web.UI.Validation.Enums.ValidationFormat.InternetUrl:isValid=this.internetUrlRegexPattern.test(value);
if(!isValid){this.get_violationMessages().push(this.get_internetUrlViolationMessage());
}break;
case Telerik.Sitefinity.Web.UI.Validation.Enums.ValidationFormat.NonAlphaNumeric:isValid=this.nonAlphaNumericRegexPattern.test(value);
if(!isValid){this.get_violationMessages().push(this.get_nonAlphaNumericViolationMessage());
}break;
case Telerik.Sitefinity.Web.UI.Validation.Enums.ValidationFormat.Numeric:isValid=this.numericRegexPattern.test(value);
if(!isValid){this.get_violationMessages().push(this.get_numericViolationMessage());
}break;
case Telerik.Sitefinity.Web.UI.Validation.Enums.ValidationFormat.Percentage:isValid=this.percentRegexPattern.test(value);
if(!isValid){this.get_violationMessages().push(this.get_percentageViolationMessage());
}break;
case Telerik.Sitefinity.Web.UI.Validation.Enums.ValidationFormat.USSocialSecurityNumber:isValid=this.uSSocialSecurityRegexPattern.test(value);
if(!isValid){this.get_violationMessages().push(this.get_uSocialSecurityNumberViolationMessage());
}break;
case Telerik.Sitefinity.Web.UI.Validation.Enums.ValidationFormat.USZipCode:isValid=this.uSZipCodeRegexPattern.test(value);
if(!isValid){this.get_violationMessages().push(this.get_uSZipCodeViolationMessage());
}break;
}return isValid;
},_validateCustomRegex:function(value,regex){var regexPattern=new XRegExp(regex,"g");
var isRegexValid=false;
if(this.get_regularExpressionSeparator()){isRegexValid=true;
if(value){regexPattern=new XRegExp(regex);
var sepRegex=new RegExp(this.get_regularExpressionSeparator());
var splitArray=value.split(sepRegex);
for(var i=0;
i<splitArray.length;
i++){var currentPart=splitArray[i];
isRegexValid=regexPattern.test(currentPart);
if(isRegexValid==false){break;
}}}}else{isRegexValid=regexPattern.test(value);
}if(!isRegexValid){var msg=this.get_regularExpressionViolationMessage();
if(msg==null){msg=this.get_regularExpression();
}this.get_violationMessages().push(msg);
return false;
}return true;
},_validateComparisons:function(value){var isValid=true;
if(value!==null&&value!==undefined&&this.get_comparingValidatorDefinitions()){var comparisonsCount=this.get_comparingValidatorDefinitions().length;
while(comparisonsCount--){if(this.get_comparingValidatorDefinitions()[comparisonsCount]){isValid=this._validateComparison(this.get_comparingValidatorDefinitions()[comparisonsCount],value)&&isValid;
}}}return isValid;
},_validateComparison:function(comparison,value){var validationOperator=comparison.Operator;
var controlToCompareId=comparison.ControlToCompare;
var violationMessage=comparison.ValidationViolationMessage;
var validationDataType=comparison.ValidationDataType;
value=this._getValueAsType(value,validationDataType);
var isValid=true;
if(controlToCompareId&&validationOperator>=0){var valueToCompareTo=this._get_controlValue(controlToCompareId);
valueToCompareTo=this._getValueAsType(valueToCompareTo,validationDataType);
isValid=this._compare(value,validationOperator,valueToCompareTo);
if(!isValid){this.get_violationMessages().push(violationMessage);
}}return isValid;
},_getValueAsType:function(value,type){switch(type){case"Number":return Number(value);
}return value;
},_get_controlValue:function(controlToCompareId){var clientID=$get_clientId(controlToCompareId);
if(!clientID){throw new "The client Id could not be resolved.";
}var componentToCompareTo=$find(clientID);
if(componentToCompareTo){return this._get_componentValue(componentToCompareTo);
}else{var controlToCompareTo=$get(clientID);
if(controlToCompareTo){return this._get_controlValue(controlToCompareTo);
}}throw new "There is no control with id: "+controlID+" to use for comparison validation.";
},_get_componentValue:function(componentToCompareTo){if(componentToCompareTo.get_value){return componentToCompareTo.get_value();
}if(componentToCompareTo.get_element){return this._get_elementValue(componentToCompareTo.get_element());
}throw new "The value of the control could not be resolved.";
},_get_elementValue:function(controlToCompareTo){if(controlToCompareTo.value){return controlToCompareTo.value;
}throw new "The value of the control could not be resolved.";
},_compare:function(firstValue,validationOperator,secondValue){if(typeof firstValue!=typeof secondValue){return false;
}var validationCompareOperator=Telerik.Sitefinity.Web.UI.Validation.Enums.ValidationCompareOperator;
switch(validationOperator){case validationCompareOperator.Equal:return firstValue===secondValue;
case validationCompareOperator.NotEqual:return firstValue!=secondValue;
case validationCompareOperator.GreaterThan:return firstValue>secondValue;
case validationCompareOperator.GreaterThanEqual:return firstValue>=secondValue;
case validationCompareOperator.LessThan:return firstValue<secondValue;
case validationCompareOperator.LessThanEqual:return firstValue<=secondValue;
default:throw"This operator is not supported";
}},_setPropertyIfChanged:function(){var propertyName=arguments[0];
propertyName=propertyName.charAt(0).toLowerCase()+propertyName.slice(1);
var value=arguments.length==3?arguments[2]:arguments[1];
var fieldName=arguments.length==3?arguments[1]:null;
if(!fieldName){fieldName="_"+propertyName;
}if(!propertyName||!this.hasOwnProperty(fieldName)){return;
}var currentValue=this[fieldName];
if(currentValue!=value){this[fieldName]=value;
this.raisePropertyChanged(propertyName);
}},_createViolationMessageElement:function(){var errorMessageElement=document.createElement(this.get_messageTagName());
jQuery(errorMessageElement).addClass(this.get_messageCssClass());
return errorMessageElement;
},get_violationMessageElement:function(){if(!this._violationMessageElement){this._violationMessageElement=this._createViolationMessageElement();
}this._violationMessageElement.innerHTML="";
var violationMessagesCount=this.get_violationMessages().length;
while(violationMessagesCount--){this._violationMessageElement.innerHTML+=" ";
this._violationMessageElement.innerHTML+=this.get_violationMessages()[violationMessagesCount];
}return this._violationMessageElement;
},get_violationMessages:function(){return this._violationMessages;
},set_violationMessages:function(value){this._violationMessages=value;
},set_expectedFormat:function(value){this._setPropertyIfChanged("expectedFormat",value);
},get_expectedFormat:function(){return this._expectedFormat;
},set_maxLength:function(value){this._setPropertyIfChanged("maxLength",value);
},get_maxLength:function(){return this._maxLength;
},set_minLength:function(value){this._setPropertyIfChanged("minLength",value);
},get_minLength:function(){return this._minLength;
},set_maxValue:function(value){this._setPropertyIfChanged("maxValue",value);
},get_maxValue:function(){return this._maxValue;
},set_minValue:function(value){this._setPropertyIfChanged("minValue",value);
},get_minValue:function(){return this._minValue;
},set_regularExpression:function(value){this._setPropertyIfChanged("regularExpression",value);
},get_regularExpression:function(){return this._regularExpression;
},set_required:function(value){this._setPropertyIfChanged("required",value);
},get_required:function(){return this._required;
},set_alphaNumericViolationMessage:function(value){this._setPropertyIfChanged("alphaNumericViolationMessage",value);
},get_alphaNumericViolationMessage:function(){return this._alphaNumericViolationMessage;
},set_currencyViolationMessage:function(value){this._setPropertyIfChanged("currencyViolationMessage",value);
},get_currencyViolationMessage:function(){return this._currencyViolationMessage;
},set_emailAddressViolationMessage:function(value){this._setPropertyIfChanged("emailAddressViolationMessage",value);
},get_emailAddressViolationMessage:function(){return this._emailAddressViolationMessage;
},set_integerViolationMessage:function(value){this._setPropertyIfChanged("integerViolationMessage",value);
},get_integerViolationMessage:function(){return this._integerViolationMessage;
},set_internetUrlViolationMessage:function(value){this._setPropertyIfChanged("internetUrlViolationMessage",value);
},get_internetUrlViolationMessage:function(){return this._internetUrlViolationMessage;
},set_maxLengthViolationMessage:function(value){this._setPropertyIfChanged("maxLengthViolationMessage",value);
},get_maxLengthViolationMessage:function(){return this._maxLengthViolationMessage;
},set_maxValueViolationMessage:function(value){this._setPropertyIfChanged("maxValueViolationMessage",value);
},get_maxValueViolationMessage:function(){return this._maxValueViolationMessage;
},set_messageCssClass:function(value){this._setPropertyIfChanged("messageCssClass",value);
},get_messageCssClass:function(){return this._messageCssClass;
},set_messageTagName:function(value){this._setPropertyIfChanged("messageTagName",value);
},get_messageTagName:function(){return this._messageTagName;
},set_minLengthViolationMessage:function(value){this._setPropertyIfChanged("minLengthViolationMessage",value);
},get_minLengthViolationMessage:function(){return this._minLengthViolationMessage;
},set_minValueViolationMessage:function(value){this._setPropertyIfChanged("minValueViolationMessage",value);
},get_minValueViolationMessage:function(){return this._minValueViolationMessage;
},set_nonAlphaNumericViolationMessage:function(value){this._setPropertyIfChanged("nonAlphaNumericViolationMessage",value);
},get_nonAlphaNumericViolationMessage:function(){return this._nonAlphaNumericViolationMessage;
},set_numericViolationMessage:function(value){this._setPropertyIfChanged("numericViolationMessage",value);
},get_numericViolationMessage:function(){return this._numericViolationMessage;
},set_percentageViolationMessage:function(value){this._setPropertyIfChanged("percentageViolationMessage",value);
},get_percentageViolationMessage:function(){return this._percentageViolationMessage;
},set_regularExpressionViolationMessage:function(value){this._setPropertyIfChanged("regularExpressionViolationMessage",value);
},get_regularExpressionViolationMessage:function(){return this._regularExpressionViolationMessage;
},set_regularExpressionSeparator:function(value){this._setPropertyIfChanged("regularExpressionSeparator",value);
},get_regularExpressionSeparator:function(){return this._regularExpressionSeparator;
},set_requiredViolationMessage:function(value){this._setPropertyIfChanged("requiredViolationMessage",value);
},get_requiredViolationMessage:function(){return this._requiredViolationMessage;
},set_uSocialSecurityNumberViolationMessage:function(value){this._setPropertyIfChanged("uSocialSecurityNumberViolationMessage",value);
},get_uSocialSecurityNumberViolationMessage:function(){return this._uSocialSecurityNumberViolationMessage;
},set_uSZipCodeViolationMessage:function(value){this._setPropertyIfChanged("uSZipCodeViolationMessage",value);
},get_uSZipCodeViolationMessage:function(){return this._uSZipCodeViolationMessage;
},set_validateIfInvisible:function(value){this._setPropertyIfChanged("validateIfInvisible",value);
},get_validateIfInvisible:function(){return this._validateIfInvisible;
},set_comparingValidatorDefinitions:function(value){this._setPropertyIfChanged("comparingValidatorDefinitions",value);
},get_comparingValidatorDefinitions:function(){return this._comparingValidatorDefinitions;
}};
Telerik.Sitefinity.Web.UI.Validation.Validator.registerClass("Telerik.Sitefinity.Web.UI.Validation.Validator",Sys.Component);
Telerik.Sitefinity.Web.UI.Validation.ValidatingEventArgs=function(value){this._value=value;
this._isValid=false;
Telerik.Sitefinity.Web.UI.Validation.ValidatingEventArgs.initializeBase(this);
};
Telerik.Sitefinity.Web.UI.Validation.ValidatingEventArgs.prototype={initialize:function(){Telerik.Sitefinity.Web.UI.Validation.ValidatingEventArgs.callBaseMethod(this,"initialize");
},dispose:function(){Telerik.Sitefinity.Web.UI.Validation.ValidatingEventArgs.callBaseMethod(this,"dispose");
},get_value:function(){return this._value;
},get_isValid:function(){return this._isValid;
},set_isValid:function(value){if(this._isValid!=value){this._isValid=value;
}}};
Telerik.Sitefinity.Web.UI.Validation.ValidatingEventArgs.registerClass("Telerik.Sitefinity.Web.UI.Validation.ValidatingEventArgs",Sys.CancelEventArgs);
Telerik.Sitefinity.Web.UI.Validation.ValidatedEventArgs=function(isValid,value){this._value=value;
this._isValid=false;
Telerik.Sitefinity.Web.UI.Validation.ValidatedEventArgs.initializeBase(this);
};
Telerik.Sitefinity.Web.UI.Validation.ValidatedEventArgs.prototype={initialize:function(){Telerik.Sitefinity.Web.UI.Validation.ValidatedEventArgs.callBaseMethod(this,"initialize");
},dispose:function(){Telerik.Sitefinity.Web.UI.Validation.ValidatedEventArgs.callBaseMethod(this,"dispose");
},get_value:function(){return this._value;
},get_isValid:function(){return this._isValid;
},set_isValid:function(value){if(this._isValid!=value){this._isValid=value;
}}};
Telerik.Sitefinity.Web.UI.Validation.ValidatedEventArgs.registerClass("Telerik.Sitefinity.Web.UI.Validation.ValidatedEventArgs",Sys.EventArgs);
Telerik.Sitefinity.Web.UI.Validation.ValidationResult=function(){this._isValid=false;
this._value=value;
Telerik.Sitefinity.Web.UI.Validation.ValidationResult.initializeBase(this);
};
Type.registerNamespace("Telerik.Sitefinity.Web.UI.Validation.Enums");
Telerik.Sitefinity.Web.UI.Validation.Enums.ValidationFormat=function(){};
Telerik.Sitefinity.Web.UI.Validation.Enums.ValidationFormat.prototype={None:0,AlphaNumeric:1,Currency:2,EmailAddress:3,Integer:4,InternetUrl:5,NonAlphaNumeric:6,Numeric:7,Percentage:8,USSocialSecurityNumber:9,USZipCode:10,Custom:11};
Telerik.Sitefinity.Web.UI.Validation.Enums.ValidationFormat.registerEnum("Telerik.Sitefinity.Web.UI.Validation.Enums.ValidationFormat");
Telerik.Sitefinity.Web.UI.Validation.Enums.ValidationCompareOperator=function(){};
Telerik.Sitefinity.Web.UI.Validation.Enums.ValidationCompareOperator.prototype={Equal:0,NotEqual:1,GreaterThan:2,GreaterThanEqual:3,LessThan:4,LessThanEqual:5,DataTypeCheck:6};
Telerik.Sitefinity.Web.UI.Validation.Enums.ValidationCompareOperator.registerEnum("Telerik.Sitefinity.Web.UI.Validation.Enums.ValidationCompareOperator");

/* END Telerik.Sitefinity.Web.UI.Validation.Scripts.Validator.js */
/* START Telerik.Sitefinity.Web.UI.Fields.Scripts.FieldControl.js */
Type.registerNamespace("Telerik.Sitefinity.Web.UI.Fields");
Telerik.Sitefinity.Web.UI.Fields.FieldControl=function(element){this._element=element;
this._dataFieldName=null;
this._dataFormatString=null;
this._description=null;
this._descriptionElement=null;
this._displayMode=null;
this._example=null;
this._exampleElement=null;
this._title=null;
this._titleElement=null;
this._validatorDefinition=null;
this._value=null;
this._defaultValue=null;
this._isBinding=false;
this._fieldName=null;
this._validator=null;
this._valueChangedDelegate=null;
this._isViolationElementPositioned=false;
this._controlErrorCssClass="";
this._uiCulture=null;
this._culture=null;
this._emptyGuid="00000000-0000-0000-0000-000000000000";
this._dataContext=null;
Telerik.Sitefinity.Web.UI.Fields.FieldControl.isValidationMessagedFocused=false;
Telerik.Sitefinity.Web.UI.Fields.FieldControl.initializeBase(this,[element]);
};
Telerik.Sitefinity.Web.UI.Fields.FieldControl.prototype={initialize:function(){if(this._valueChangedDelegate==null){this._valueChangedDelegate=Function.createDelegate(this,this._valueChangedHandler);
}if(this._validatorDefinition){this._validatorDefinition=Sys.Serialization.JavaScriptSerializer.deserialize(this._validatorDefinition);
this._validator=new Telerik.Sitefinity.Web.UI.Validation.Validator(this._validatorDefinition);
}if(this._controlErrorCssClass==null){this._controlErrorCssClass="";
}Telerik.Sitefinity.Web.UI.Fields.FieldControl.callBaseMethod(this,"initialize");
},dispose:function(){if(this._valueChangedDelegate!=null){delete this._valueChangedDelegate;
}Telerik.Sitefinity.Web.UI.Fields.FieldControl.callBaseMethod(this,"dispose");
},add_valueChanged:function(delegate){this.get_events().addHandler("valueChanged",delegate);
},remove_valueChanged:function(delegate){this.get_events().removeHandler("valueChanged",delegate);
},add_reset:function(delegate){this.get_events().addHandler("reset",delegate);
},remove_reset:function(delegate){this.get_events().removeHandler("reset",delegate);
},add_doExpand:function(delegate){this.get_events().addHandler("doExpand",delegate);
},remove_doExpand:function(delegate){this.get_events().removeHandler("doExpand",delegate);
},add_doCollapse:function(delegate){this.get_events().addHandler("doCollapse",delegate);
},remove_doCollapse:function(delegate){this.get_events().removeHandler("doCollapse",delegate);
},add_dataBound:function(delegate){this.get_events().addHandler("dataBound",delegate);
},remove_dataBound:function(delegate){this.get_events().removeHandler("dataBound",delegate);
},reset:function(){this._clearViolationMessage();
this._resetHandler();
},validate:function(){if(this._validator&&this._isToValidate()){var isValid=this._validator.validate(this.get_value());
var addWrappingErrorCssClass=this._controlErrorCssClass.length>0;
var violationMessageElement=this._validator.get_violationMessageElement();
if(isValid){if(addWrappingErrorCssClass){jQuery(this._element).removeClass(this._controlErrorCssClass);
}violationMessageElement.style.display="none";
}else{if(addWrappingErrorCssClass){if(!jQuery(this._element).hasClass(this._controlErrorCssClass)){jQuery(this._element).addClass(this._controlErrorCssClass);
}}this._expandParentSections(this._element);
this._showViolationMessageElement(violationMessageElement);
}return isValid;
}return true;
},raise_dataBound:function(){if(typeof this.get_events=="function"){var h=this.get_events().getHandler("dataBound");
if(h){h(this,Sys.EventArgs.Empty);
}return Sys.EventArgs.Empty;
}},focusControlByTabKey:function(keyDownEventArgs){if(keyDownEventArgs.keyCode==Sys.UI.Key.tab){var currentTabIndex=parseInt(this.get_tabIndex());
var direction=1;
var element=null;
if(!currentTabIndex){return;
}if(keyDownEventArgs.shiftKey){direction=-1;
element=this.findPreviousElementByTabIndex(currentTabIndex);
}else{element=this.findNextElementByTabIndex(currentTabIndex);
}if(element){element.focus();
if(keyDownEventArgs.stopPropagation){keyDownEventArgs.stopPropagation();
}if(keyDownEventArgs.preventDefault){keyDownEventArgs.preventDefault();
}}}},findElementByTabIndex:function(tabIndex){if(tabIndex>0){var element=jQuery(this._element).parents().find("[tabIndex='"+tabIndex+"']:visible");
if(element.length>0){return element[element.length-1];
}}return null;
},findNextElementByTabIndex:function(tabIndex){var closestTabIndex=Infinity;
var elements=jQuery(this._element).parents().find(":visible").filter(function(){var ti=$(this).attr("tabIndex");
if(ti){ti=parseInt(ti);
if(ti>tabIndex&&ti<=closestTabIndex){closestTabIndex=ti;
return true;
}}return false;
});
if(elements&&elements.length>0){return elements[0];
}return null;
},findPreviousElementByTabIndex:function(tabIndex){var closestTabIndex=-Infinity;
var elements=jQuery(this._element).parents().find(":visible").filter(function(){var ti=$(this).attr("tabIndex");
if(ti){ti=parseInt(ti);
if(ti<tabIndex&&ti>=closestTabIndex&&ti>=1){closestTabIndex=ti;
return true;
}}return false;
});
if(elements&&elements.length>0){return elements[elements.length-1];
}return null;
},_valueChangedHandler:function(){if(typeof this.get_events=="function"){var h=this.get_events().getHandler("valueChanged");
if(h){h(this,Sys.EventArgs.Empty);
}return Sys.EventArgs.Empty;
}},_resetHandler:function(){if(typeof this.get_events=="function"){var h=this.get_events().getHandler("reset");
if(h){h(this,Sys.EventArgs.Empty);
}return Sys.EventArgs.Empty;
}},_doExpandHandler:function(){if(typeof this.get_events=="function"){var h=this.get_events().getHandler("doExpand");
if(h){h(this,Sys.EventArgs.Empty);
}return Sys.EventArgs.Empty;
}},_doCollapseHandler:function(){if(typeof this.get_events=="function"){var h=this.get_events().getHandler("doCollapse");
if(h){h(this,Sys.EventArgs.Empty);
}return Sys.EventArgs.Empty;
}},_clearViolationMessage:function(){var element=jQuery(this.get_element()).find("."+this._getViolationMessageClassName());
if(element.length>0){element.hide();
}},_showViolationMessageElement:function(element){if(!this._isViolationElementPositioned){this.get_element().appendChild(element);
this._isViolationElementPositioned=true;
}element.style.display="";
jQuery(element).addClass(this._getViolationMessageClassName());
var fieldControl=Telerik.Sitefinity.Web.UI.Fields.FieldControl;
if(!fieldControl.isValidationMessagedFocused){fieldControl.isValidationMessagedFocused=true;
jQuery("html, body").scrollTop(element.offsetTop);
}},_getViolationMessageClassName:function(){return"violationMessage"+this.get_id();
},_isToValidate:function(){if((!this._validator._required&&!this.get_value())){return false;
}else{return(this._validator.get_validateIfInvisible()||$(this._element).is(":visible"))&&this.get_displayMode()===Telerik.Sitefinity.Web.UI.Fields.FieldDisplayMode.Write;
}},_expandParentSections:function(element){var elementParent=jQuery(element).parent();
while(elementParent.length!=0){if(jQuery(elementParent).hasClass("sfExpandableForm")){if(!jQuery(elementParent).hasClass("sfExpandedForm")){jQuery(elementParent).addClass("sfExpandedForm");
}var collapsedElement=jQuery(elementParent).find(".sfCollapsedTarget");
if(collapsedElement.length!=0){collapsedElement.removeClass("sfCollapsedTarget");
collapsedElement.addClass("sfExpandedTarget");
}}elementParent=elementParent.parent();
}},isChanged:function(){var notChanged=(this._value==this.get_value());
if(notChanged){return false;
}else{return true;
}},hasAttribute:function(value){var attr=jQuery(this._element).attr(value);
if(typeof attr!=="undefined"&&attr!==false){return true;
}return false;
},getAttributeValue:function(value){var result=jQuery(this._element).attr(value);
if(result){return result;
}return"";
},get_dataFieldName:function(){return this._dataFieldName;
},set_dataFieldName:function(value){this._dataFieldName=value;
},get_dataFormatString:function(){return this._dataFormatString;
},set_dataFormatString:function(value){this._dataFormatString=value;
},get_description:function(){return this._description;
},set_description:function(value){this._description=value;
if(this._descriptionElement){this._descriptionElement.innerHTML=this._description;
}},get_descriptionElement:function(){return this._descriptionElement;
},set_descriptionElement:function(value){this._descriptionElement=value;
},get_displayMode:function(){return this._displayMode;
},set_displayMode:function(value){this._displayMode=value;
},get_example:function(){return this._example;
},set_example:function(value){this._example=value;
if(this._exampleElement){this._exampleElement.innerHTML=this._example;
}},get_exampleElement:function(){return this._exampleElement;
},set_exampleElement:function(value){this._exampleElement=value;
},get_title:function(){return this._title;
},set_title:function(value){this._title=value;
if(this._titleElement){this._titleElement.innerHTML=this._title;
}},get_titleElement:function(){return this._titleElement;
},set_titleElement:function(value){this._titleElement=value;
},get_validatorDefinition:function(){return this._validatorDefinition;
},set_validatorDefinition:function(value){this._validatorDefinition=value;
},get_validator:function(){return this._validator;
},set_validator:function(value){this._validator=value;
},get_isBinding:function(){return this._isBinding;
},set_isBinding:function(value){this._isBinding=value;
},get_value:function(){return this._value;
},set_value:function(value){this._value=value;
},get_defaultValue:function(){return this._defaultValue;
},set_defaultValue:function(value){this._defaultValue=value;
},get_tabIndex:function(){var result=jQuery(this._element).attr("tabIndex");
if(result){return result;
}return -1;
},set_tabIndex:function(value){jQuery(this._element).attr("tabIndex",value);
},blur:function(){},focus:function(){},clearViolationMessage:function(){this._clearViolationMessage();
},get_violationMessages:function(){return this._validator.get_violationMessages();
},get_validator:function(){return this._validator;
},get_controlErrorCssClass:function(){return this._controlErrorCssClass;
},set_controlErrorCssClass:function(value){this._controlErrorCssClass=value;
},set_uiCulture:function(culture){this._uiCulture=culture;
},get_uiCulture:function(){return this._uiCulture;
},set_culture:function(culture){this._culture=culture;
},get_culture:function(){return this._culture;
},get_fieldName:function(){return this._fieldName;
},set_fieldName:function(value){this._fieldName=value;
},get_dataContext:function(){return this._dataContext;
},set_dataContext:function(value){this._dataContext=value;
},};
Telerik.Sitefinity.Web.UI.Fields.FieldControl.registerClass("Telerik.Sitefinity.Web.UI.Fields.FieldControl",Sys.UI.Control,Telerik.Sitefinity.Web.UI.Fields.IField);

/* END Telerik.Sitefinity.Web.UI.Fields.Scripts.FieldControl.js */
/* START Telerik.Sitefinity.Web.UI.Fields.Scripts.FieldDisplayMode.js */
Type.registerNamespace("Telerik.Sitefinity.Web.UI.Fields");
Telerik.Sitefinity.Web.UI.Fields.FieldDisplayMode=function(){};
Telerik.Sitefinity.Web.UI.Fields.FieldDisplayMode.prototype={Read:0,Write:1};
Telerik.Sitefinity.Web.UI.Fields.FieldDisplayMode.registerEnum("Telerik.Sitefinity.Web.UI.Fields.FieldDisplayMode");

/* END Telerik.Sitefinity.Web.UI.Fields.Scripts.FieldDisplayMode.js */
/* START Telerik.Sitefinity.Resources.Scripts.xregexp-min.js */
// XRegExp 1.5.0 without native overrides!!
var XRegExp; if (XRegExp) { throw Error("can't load XRegExp twice in the same frame"); } (function () { XRegExp = function (pattern, flags) { var output = [], currScope = XRegExp.OUTSIDE_CLASS, pos = 0, context, tokenResult, match, chr, regex; if (XRegExp.isRegExp(pattern)) { if (flags !== undefined) { throw TypeError("can't supply flags when constructing one RegExp from another"); } return clone(pattern); } if (isInsideConstructor) { throw Error("can't call the XRegExp constructor within token definition functions"); } flags = flags || ""; context = { hasNamedCapture: false, captureNames: [], hasFlag: function (flag) { return flags.indexOf(flag) > -1; }, setFlag: function (flag) { flags += flag; } }; while (pos < pattern.length) { tokenResult = runTokens(pattern, pos, currScope, context); if (tokenResult) { output.push(tokenResult.output); pos += (tokenResult.match[0].length || 1); } else { if (match = real.exec.call(nativeTokens[currScope], pattern.slice(pos))) { output.push(match[0]); pos += match[0].length; } else { chr = pattern.charAt(pos); if (chr === "[") { currScope = XRegExp.INSIDE_CLASS; } else { if (chr === "]") { currScope = XRegExp.OUTSIDE_CLASS; } } output.push(chr); pos++; } } } regex = RegExp(output.join(""), real.replace.call(flags, flagClip, "")); regex._xregexp = { source: pattern, captureNames: context.hasNamedCapture ? context.captureNames : null }; return regex; }; XRegExp.version = "1.5.0"; XRegExp.INSIDE_CLASS = 1; XRegExp.OUTSIDE_CLASS = 2; var replacementToken = /\$(?:(\d\d?|[$&`'])|{([$\w]+)})/g, flagClip = /[^gimy]+|([\s\S])(?=[\s\S]*\1)/g, quantifier = /^(?:[?*+]|{\d+(?:,\d*)?})\??/, isInsideConstructor = false, tokens = [], real = { exec: RegExp.prototype.exec, test: RegExp.prototype.test, match: String.prototype.match, replace: String.prototype.replace, split: String.prototype.split }, compliantExecNpcg = real.exec.call(/()??/, "")[1] === undefined, compliantLastIndexIncrement = function () { var x = /^/g; real.test.call(x, ""); return !x.lastIndex; } (), compliantLastIndexReset = function () { var x = /x/g; real.replace.call("x", x, ""); return !x.lastIndex; } (), hasNativeY = RegExp.prototype.sticky !== undefined, nativeTokens = {}; nativeTokens[XRegExp.INSIDE_CLASS] = /^(?:\\(?:[0-3][0-7]{0,2}|[4-7][0-7]?|x[\dA-Fa-f]{2}|u[\dA-Fa-f]{4}|c[A-Za-z]|[\s\S]))/; nativeTokens[XRegExp.OUTSIDE_CLASS] = /^(?:\\(?:0(?:[0-3][0-7]{0,2}|[4-7][0-7]?)?|[1-9]\d*|x[\dA-Fa-f]{2}|u[\dA-Fa-f]{4}|c[A-Za-z]|[\s\S])|\(\?[:=!]|[?*+]\?|{\d+(?:,\d*)?}\??)/; XRegExp.addToken = function (regex, handler, scope, trigger) { tokens.push({ pattern: clone(regex, "g" + (hasNativeY ? "y" : "")), handler: handler, scope: scope || XRegExp.OUTSIDE_CLASS, trigger: trigger || null }); }; XRegExp.cache = function (pattern, flags) { var key = pattern + "/" + (flags || ""); return XRegExp.cache[key] || (XRegExp.cache[key] = XRegExp(pattern, flags)); }; XRegExp.copyAsGlobal = function (regex) { return clone(regex, "g"); }; XRegExp.escape = function (str) { return str.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&"); }; XRegExp.execAt = function (str, regex, pos, anchored) { regex = clone(regex, "g" + ((anchored && hasNativeY) ? "y" : "")); regex.lastIndex = pos = pos || 0; var match = regex.exec(str); if (anchored) { return (match && match.index === pos) ? match : null; } else { return match; } }; XRegExp.freezeTokens = function () { XRegExp.addToken = function () { throw Error("can't run addToken after freezeTokens"); }; }; XRegExp.isRegExp = function (o) { return Object.prototype.toString.call(o) === "[object RegExp]"; }; XRegExp.iterate = function (str, origRegex, callback, context) { var regex = clone(origRegex, "g"), i = -1, match; while (match = regex.exec(str)) { callback.call(context, match, ++i, str, regex); if (regex.lastIndex === match.index) { regex.lastIndex++; } } if (origRegex.global) { origRegex.lastIndex = 0; } }; XRegExp.matchChain = function (str, chain) { return function recurseChain(values, level) { var item = chain[level].regex ? chain[level] : { regex: chain[level] }, regex = clone(item.regex, "g"), matches = [], i; for (i = 0; i < values.length; i++) { XRegExp.iterate(values[i], regex, function (match) { matches.push(item.backref ? (match[item.backref] || "") : match[0]); }); } return ((level === chain.length - 1) || !matches.length) ? matches : recurseChain(matches, level + 1); } ([str], 0); }; RegExp.prototype.apply = function (context, args) { return this.exec(args[0]); }; RegExp.prototype.call = function (context, str) { return this.exec(str); }; function clone(regex, additionalFlags) { if (!XRegExp.isRegExp(regex)) { throw TypeError("type RegExp expected"); } var x = regex._xregexp; regex = XRegExp(regex.source, getNativeFlags(regex) + (additionalFlags || "")); if (x) { regex._xregexp = { source: x.source, captureNames: x.captureNames ? x.captureNames.slice(0) : null }; } return regex; } function getNativeFlags(regex) { return (regex.global ? "g" : "") + (regex.ignoreCase ? "i" : "") + (regex.multiline ? "m" : "") + (regex.extended ? "x" : "") + (regex.sticky ? "y" : ""); } function runTokens(pattern, index, scope, context) { var i = tokens.length, result, match, t; isInsideConstructor = true; try { while (i--) { t = tokens[i]; if ((scope & t.scope) && (!t.trigger || t.trigger.call(context))) { t.pattern.lastIndex = index; match = t.pattern.exec(pattern); if (match && match.index === index) { result = { output: t.handler.call(context, match, scope), match: match }; break; } } } } catch (err) { throw err; } finally { isInsideConstructor = false; } return result; } function indexOf(array, item, from) { if (Array.prototype.indexOf) { return array.indexOf(item, from); } for (var i = from || 0; i < array.length; i++) { if (array[i] === item) { return i; } } return -1; } XRegExp.addToken(/\(\?#[^)]*\)/, function (match) { return real.test.call(quantifier, match.input.slice(match.index + match[0].length)) ? "" : "(?:)"; }); XRegExp.addToken(/\((?!\?)/, function () { this.captureNames.push(null); return "("; }); XRegExp.addToken(/\(\?<([$\w]+)>/, function (match) { this.captureNames.push(match[1]); this.hasNamedCapture = true; return "("; }); XRegExp.addToken(/\\k<([\w$]+)>/, function (match) { var index = indexOf(this.captureNames, match[1]); return index > -1 ? "\\" + (index + 1) + (isNaN(match.input.charAt(match.index + match[0].length)) ? "" : "(?:)") : match[0]; }); XRegExp.addToken(/\[\^?]/, function (match) { return match[0] === "[]" ? "\\b\\B" : "[\\s\\S]"; }); XRegExp.addToken(/^\(\?([imsx]+)\)/, function (match) { this.setFlag(match[1]); return ""; }); XRegExp.addToken(/(?:\s+|#.*)+/, function (match) { return real.test.call(quantifier, match.input.slice(match.index + match[0].length)) ? "" : "(?:)"; }, XRegExp.OUTSIDE_CLASS, function () { return this.hasFlag("x"); }); XRegExp.addToken(/\./, function () { return "[\\s\\S]"; }, XRegExp.OUTSIDE_CLASS, function () { return this.hasFlag("s"); }); })();
/* END Telerik.Sitefinity.Resources.Scripts.xregexp-min.js */
/* START Telerik.Sitefinity.Resources.Scripts.xregexp-unicode-base.js */
/*
XRegExp Unicode plugin base 0.5
(c) 2008-2010 Steven Levithan
MIT License
<http://xregexp.com>
Uses the Unicode 5.2 character database

The Unicode plugin base adds support for the \p{L} token only (Unicode category Letter). Plugin
packages are available that add support for the remaining Unicode categories, as well as Unicode
scripts and blocks.

All Unicode tokens can be inverted by using an uppercase P; e.g., \P{L} matches any character not
in Unicode's Letter category. Negated Unicode tokens are not supported within character classes.

Letter case, spaces, hyphens, and underscores are ignored when comparing Unicode token names.
*/

var XRegExp;

if (!XRegExp) {
    throw ReferenceError("XRegExp must be loaded before the Unicode plugin");
}

(function () {

    var unicode = {}; // protected storage for package tokens

    XRegExp.addUnicodePackage = function (pack) {
        var codePoint = /\w{4}/g,
            clip = /[- _]+/g,
            name, p;
        for (p in pack) {
            if (pack.hasOwnProperty(p)) {
                name = p.replace(clip, "").toLowerCase();
                // disallow overriding properties that have already been added
                if (!unicode.hasOwnProperty(name)) {
                    unicode[name] = pack[p].replace(codePoint, "\\u$&");
                }
            }
        }
    };

    XRegExp.addToken(
        /\\([pP]){(\^?)([^}]*)}/,
        function (match, scope) {
            var negated = (match[1] === "P" || match[2]),
                item = match[3].replace(/[- _]+/g, "").toLowerCase();

            // \p{}, \P{}, and \p{^} are valid, but the double negative \P{^} isn't
            if (match[1] === "P" && match[2])
                throw SyntaxError("erroneous characters: " + match[0]);
            if (negated && scope === XRegExp.INSIDE_CLASS)
                throw SyntaxError("not supported in character classes: \\" + match[1] + "{" + match[2] + "\u22EF}");
            if (!unicode.hasOwnProperty(item))
                throw SyntaxError("invalid or unsupported Unicode item: " + match[0]);

            return scope === XRegExp.OUTSIDE_CLASS ?
                "[" + (negated ? "^" : "") + unicode[item] + "]" :
                unicode[item];
        },
        XRegExp.INSIDE_CLASS | XRegExp.OUTSIDE_CLASS
    );

    XRegExp.addUnicodePackage({
        L: "0041-005A0061-007A00AA00B500BA00C0-00D600D8-00F600F8-02C102C6-02D102E0-02E402EC02EE0370-037403760377037A-037D03860388-038A038C038E-03A103A3-03F503F7-0481048A-05250531-055605590561-058705D0-05EA05F0-05F20621-064A066E066F0671-06D306D506E506E606EE06EF06FA-06FC06FF07100712-072F074D-07A507B107CA-07EA07F407F507FA0800-0815081A082408280904-0939093D09500958-0961097109720979-097F0985-098C098F09900993-09A809AA-09B009B209B6-09B909BD09CE09DC09DD09DF-09E109F009F10A05-0A0A0A0F0A100A13-0A280A2A-0A300A320A330A350A360A380A390A59-0A5C0A5E0A72-0A740A85-0A8D0A8F-0A910A93-0AA80AAA-0AB00AB20AB30AB5-0AB90ABD0AD00AE00AE10B05-0B0C0B0F0B100B13-0B280B2A-0B300B320B330B35-0B390B3D0B5C0B5D0B5F-0B610B710B830B85-0B8A0B8E-0B900B92-0B950B990B9A0B9C0B9E0B9F0BA30BA40BA8-0BAA0BAE-0BB90BD00C05-0C0C0C0E-0C100C12-0C280C2A-0C330C35-0C390C3D0C580C590C600C610C85-0C8C0C8E-0C900C92-0CA80CAA-0CB30CB5-0CB90CBD0CDE0CE00CE10D05-0D0C0D0E-0D100D12-0D280D2A-0D390D3D0D600D610D7A-0D7F0D85-0D960D9A-0DB10DB3-0DBB0DBD0DC0-0DC60E01-0E300E320E330E40-0E460E810E820E840E870E880E8A0E8D0E94-0E970E99-0E9F0EA1-0EA30EA50EA70EAA0EAB0EAD-0EB00EB20EB30EBD0EC0-0EC40EC60EDC0EDD0F000F40-0F470F49-0F6C0F88-0F8B1000-102A103F1050-1055105A-105D106110651066106E-10701075-1081108E10A0-10C510D0-10FA10FC1100-1248124A-124D1250-12561258125A-125D1260-1288128A-128D1290-12B012B2-12B512B8-12BE12C012C2-12C512C8-12D612D8-13101312-13151318-135A1380-138F13A0-13F41401-166C166F-167F1681-169A16A0-16EA1700-170C170E-17111720-17311740-17511760-176C176E-17701780-17B317D717DC1820-18771880-18A818AA18B0-18F51900-191C1950-196D1970-19741980-19AB19C1-19C71A00-1A161A20-1A541AA71B05-1B331B45-1B4B1B83-1BA01BAE1BAF1C00-1C231C4D-1C4F1C5A-1C7D1CE9-1CEC1CEE-1CF11D00-1DBF1E00-1F151F18-1F1D1F20-1F451F48-1F4D1F50-1F571F591F5B1F5D1F5F-1F7D1F80-1FB41FB6-1FBC1FBE1FC2-1FC41FC6-1FCC1FD0-1FD31FD6-1FDB1FE0-1FEC1FF2-1FF41FF6-1FFC2071207F2090-209421022107210A-211321152119-211D212421262128212A-212D212F-2139213C-213F2145-2149214E218321842C00-2C2E2C30-2C5E2C60-2CE42CEB-2CEE2D00-2D252D30-2D652D6F2D80-2D962DA0-2DA62DA8-2DAE2DB0-2DB62DB8-2DBE2DC0-2DC62DC8-2DCE2DD0-2DD62DD8-2DDE2E2F300530063031-3035303B303C3041-3096309D-309F30A1-30FA30FC-30FF3105-312D3131-318E31A0-31B731F0-31FF3400-4DB54E00-9FCBA000-A48CA4D0-A4FDA500-A60CA610-A61FA62AA62BA640-A65FA662-A66EA67F-A697A6A0-A6E5A717-A71FA722-A788A78BA78CA7FB-A801A803-A805A807-A80AA80C-A822A840-A873A882-A8B3A8F2-A8F7A8FBA90A-A925A930-A946A960-A97CA984-A9B2A9CFAA00-AA28AA40-AA42AA44-AA4BAA60-AA76AA7AAA80-AAAFAAB1AAB5AAB6AAB9-AABDAAC0AAC2AADB-AADDABC0-ABE2AC00-D7A3D7B0-D7C6D7CB-D7FBF900-FA2DFA30-FA6DFA70-FAD9FB00-FB06FB13-FB17FB1DFB1F-FB28FB2A-FB36FB38-FB3CFB3EFB40FB41FB43FB44FB46-FBB1FBD3-FD3DFD50-FD8FFD92-FDC7FDF0-FDFBFE70-FE74FE76-FEFCFF21-FF3AFF41-FF5AFF66-FFBEFFC2-FFC7FFCA-FFCFFFD2-FFD7FFDA-FFDC",
        Ll: "0061-007A00B500DF-00F600F8-00FF01010103010501070109010B010D010F01110113011501170119011B011D011F01210123012501270129012B012D012F01310133013501370138013A013C013E014001420144014601480149014B014D014F01510153015501570159015B015D015F01610163016501670169016B016D016F0171017301750177017A017C017E-0180018301850188018C018D019201950199-019B019E01A101A301A501A801AA01AB01AD01B001B401B601B901BA01BD-01BF01C601C901CC01CE01D001D201D401D601D801DA01DC01DD01DF01E101E301E501E701E901EB01ED01EF01F001F301F501F901FB01FD01FF02010203020502070209020B020D020F02110213021502170219021B021D021F02210223022502270229022B022D022F02310233-0239023C023F0240024202470249024B024D024F-02930295-02AF037103730377037B-037D039003AC-03CE03D003D103D5-03D703D903DB03DD03DF03E103E303E503E703E903EB03ED03EF-03F303F503F803FB03FC0430-045F04610463046504670469046B046D046F04710473047504770479047B047D047F0481048B048D048F04910493049504970499049B049D049F04A104A304A504A704A904AB04AD04AF04B104B304B504B704B904BB04BD04BF04C204C404C604C804CA04CC04CE04CF04D104D304D504D704D904DB04DD04DF04E104E304E504E704E904EB04ED04EF04F104F304F504F704F904FB04FD04FF05010503050505070509050B050D050F05110513051505170519051B051D051F05210523052505270561-05871D00-1D2B1D6B-1D771D79-1D9A1E011E031E051E071E091E0B1E0D1E0F1E111E131E151E171E191E1B1E1D1E1F1E211E231E251E271E291E2B1E2D1E2F1E311E331E351E371E391E3B1E3D1E3F1E411E431E451E471E491E4B1E4D1E4F1E511E531E551E571E591E5B1E5D1E5F1E611E631E651E671E691E6B1E6D1E6F1E711E731E751E771E791E7B1E7D1E7F1E811E831E851E871E891E8B1E8D1E8F1E911E931E95-1E9D1E9F1EA11EA31EA51EA71EA91EAB1EAD1EAF1EB11EB31EB51EB71EB91EBB1EBD1EBF1EC11EC31EC51EC71EC91ECB1ECD1ECF1ED11ED31ED51ED71ED91EDB1EDD1EDF1EE11EE31EE51EE71EE91EEB1EED1EEF1EF11EF31EF51EF71EF91EFB1EFD1EFF-1F071F10-1F151F20-1F271F30-1F371F40-1F451F50-1F571F60-1F671F70-1F7D1F80-1F871F90-1F971FA0-1FA71FB0-1FB41FB61FB71FBE1FC2-1FC41FC61FC71FD0-1FD31FD61FD71FE0-1FE71FF2-1FF41FF61FF7210A210E210F2113212F21342139213C213D2146-2149214E21842C30-2C5E2C612C652C662C682C6A2C6C2C712C732C742C76-2C7B2C812C832C852C872C892C8B2C8D2C8F2C912C932C952C972C992C9B2C9D2C9F2CA12CA32CA52CA72CA92CAB2CAD2CAF2CB12CB32CB52CB72CB92CBB2CBD2CBF2CC12CC32CC52CC72CC92CCB2CCD2CCF2CD12CD32CD52CD72CD92CDB2CDD2CDF2CE12CE32CE42CEC2CEE2CF32D00-2D252D272D2DA641A643A645A647A649A64BA64DA64FA651A653A655A657A659A65BA65DA65FA661A663A665A667A669A66BA66DA681A683A685A687A689A68BA68DA68FA691A693A695A697A723A725A727A729A72BA72DA72F-A731A733A735A737A739A73BA73DA73FA741A743A745A747A749A74BA74DA74FA751A753A755A757A759A75BA75DA75FA761A763A765A767A769A76BA76DA76FA771-A778A77AA77CA77FA781A783A785A787A78CA78EA791A793A7A1A7A3A7A5A7A7A7A9A7FAFB00-FB06FB13-FB17FF41-FF5A",
        Lu: "0041-005A00C0-00D600D8-00DE01000102010401060108010A010C010E01100112011401160118011A011C011E01200122012401260128012A012C012E01300132013401360139013B013D013F0141014301450147014A014C014E01500152015401560158015A015C015E01600162016401660168016A016C016E017001720174017601780179017B017D018101820184018601870189-018B018E-0191019301940196-0198019C019D019F01A001A201A401A601A701A901AC01AE01AF01B1-01B301B501B701B801BC01C401C701CA01CD01CF01D101D301D501D701D901DB01DE01E001E201E401E601E801EA01EC01EE01F101F401F6-01F801FA01FC01FE02000202020402060208020A020C020E02100212021402160218021A021C021E02200222022402260228022A022C022E02300232023A023B023D023E02410243-02460248024A024C024E03700372037603860388-038A038C038E038F0391-03A103A3-03AB03CF03D2-03D403D803DA03DC03DE03E003E203E403E603E803EA03EC03EE03F403F703F903FA03FD-042F04600462046404660468046A046C046E04700472047404760478047A047C047E0480048A048C048E04900492049404960498049A049C049E04A004A204A404A604A804AA04AC04AE04B004B204B404B604B804BA04BC04BE04C004C104C304C504C704C904CB04CD04D004D204D404D604D804DA04DC04DE04E004E204E404E604E804EA04EC04EE04F004F204F404F604F804FA04FC04FE05000502050405060508050A050C050E05100512051405160518051A051C051E05200522052405260531-055610A0-10C510C710CD1E001E021E041E061E081E0A1E0C1E0E1E101E121E141E161E181E1A1E1C1E1E1E201E221E241E261E281E2A1E2C1E2E1E301E321E341E361E381E3A1E3C1E3E1E401E421E441E461E481E4A1E4C1E4E1E501E521E541E561E581E5A1E5C1E5E1E601E621E641E661E681E6A1E6C1E6E1E701E721E741E761E781E7A1E7C1E7E1E801E821E841E861E881E8A1E8C1E8E1E901E921E941E9E1EA01EA21EA41EA61EA81EAA1EAC1EAE1EB01EB21EB41EB61EB81EBA1EBC1EBE1EC01EC21EC41EC61EC81ECA1ECC1ECE1ED01ED21ED41ED61ED81EDA1EDC1EDE1EE01EE21EE41EE61EE81EEA1EEC1EEE1EF01EF21EF41EF61EF81EFA1EFC1EFE1F08-1F0F1F18-1F1D1F28-1F2F1F38-1F3F1F48-1F4D1F591F5B1F5D1F5F1F68-1F6F1FB8-1FBB1FC8-1FCB1FD8-1FDB1FE8-1FEC1FF8-1FFB21022107210B-210D2110-211221152119-211D212421262128212A-212D2130-2133213E213F214521832C00-2C2E2C602C62-2C642C672C692C6B2C6D-2C702C722C752C7E-2C802C822C842C862C882C8A2C8C2C8E2C902C922C942C962C982C9A2C9C2C9E2CA02CA22CA42CA62CA82CAA2CAC2CAE2CB02CB22CB42CB62CB82CBA2CBC2CBE2CC02CC22CC42CC62CC82CCA2CCC2CCE2CD02CD22CD42CD62CD82CDA2CDC2CDE2CE02CE22CEB2CED2CF2A640A642A644A646A648A64AA64CA64EA650A652A654A656A658A65AA65CA65EA660A662A664A666A668A66AA66CA680A682A684A686A688A68AA68CA68EA690A692A694A696A722A724A726A728A72AA72CA72EA732A734A736A738A73AA73CA73EA740A742A744A746A748A74AA74CA74EA750A752A754A756A758A75AA75CA75EA760A762A764A766A768A76AA76CA76EA779A77BA77DA77EA780A782A784A786A78BA78DA790A792A7A0A7A2A7A4A7A6A7A8A7AAFF21-FF3A",
        Lt: "01C501C801CB01F21F88-1F8F1F98-1F9F1FA8-1FAF1FBC1FCC1FFC",
        Lm: "02B0-02C102C6-02D102E0-02E402EC02EE0374037A0559064006E506E607F407F507FA081A0824082809710E460EC610FC17D718431AA71C78-1C7D1D2C-1D6A1D781D9B-1DBF2071207F2090-209C2C7C2C7D2D6F2E2F30053031-3035303B309D309E30FC-30FEA015A4F8-A4FDA60CA67FA717-A71FA770A788A7F8A7F9A9CFAA70AADDAAF3AAF4FF70FF9EFF9F",
        Lo: "00AA00BA01BB01C0-01C3029405D0-05EA05F0-05F20620-063F0641-064A066E066F0671-06D306D506EE06EF06FA-06FC06FF07100712-072F074D-07A507B107CA-07EA0800-08150840-085808A008A2-08AC0904-0939093D09500958-09610972-09770979-097F0985-098C098F09900993-09A809AA-09B009B209B6-09B909BD09CE09DC09DD09DF-09E109F009F10A05-0A0A0A0F0A100A13-0A280A2A-0A300A320A330A350A360A380A390A59-0A5C0A5E0A72-0A740A85-0A8D0A8F-0A910A93-0AA80AAA-0AB00AB20AB30AB5-0AB90ABD0AD00AE00AE10B05-0B0C0B0F0B100B13-0B280B2A-0B300B320B330B35-0B390B3D0B5C0B5D0B5F-0B610B710B830B85-0B8A0B8E-0B900B92-0B950B990B9A0B9C0B9E0B9F0BA30BA40BA8-0BAA0BAE-0BB90BD00C05-0C0C0C0E-0C100C12-0C280C2A-0C330C35-0C390C3D0C580C590C600C610C85-0C8C0C8E-0C900C92-0CA80CAA-0CB30CB5-0CB90CBD0CDE0CE00CE10CF10CF20D05-0D0C0D0E-0D100D12-0D3A0D3D0D4E0D600D610D7A-0D7F0D85-0D960D9A-0DB10DB3-0DBB0DBD0DC0-0DC60E01-0E300E320E330E40-0E450E810E820E840E870E880E8A0E8D0E94-0E970E99-0E9F0EA1-0EA30EA50EA70EAA0EAB0EAD-0EB00EB20EB30EBD0EC0-0EC40EDC-0EDF0F000F40-0F470F49-0F6C0F88-0F8C1000-102A103F1050-1055105A-105D106110651066106E-10701075-1081108E10D0-10FA10FD-1248124A-124D1250-12561258125A-125D1260-1288128A-128D1290-12B012B2-12B512B8-12BE12C012C2-12C512C8-12D612D8-13101312-13151318-135A1380-138F13A0-13F41401-166C166F-167F1681-169A16A0-16EA1700-170C170E-17111720-17311740-17511760-176C176E-17701780-17B317DC1820-18421844-18771880-18A818AA18B0-18F51900-191C1950-196D1970-19741980-19AB19C1-19C71A00-1A161A20-1A541B05-1B331B45-1B4B1B83-1BA01BAE1BAF1BBA-1BE51C00-1C231C4D-1C4F1C5A-1C771CE9-1CEC1CEE-1CF11CF51CF62135-21382D30-2D672D80-2D962DA0-2DA62DA8-2DAE2DB0-2DB62DB8-2DBE2DC0-2DC62DC8-2DCE2DD0-2DD62DD8-2DDE3006303C3041-3096309F30A1-30FA30FF3105-312D3131-318E31A0-31BA31F0-31FF3400-4DB54E00-9FCCA000-A014A016-A48CA4D0-A4F7A500-A60BA610-A61FA62AA62BA66EA6A0-A6E5A7FB-A801A803-A805A807-A80AA80C-A822A840-A873A882-A8B3A8F2-A8F7A8FBA90A-A925A930-A946A960-A97CA984-A9B2AA00-AA28AA40-AA42AA44-AA4BAA60-AA6FAA71-AA76AA7AAA80-AAAFAAB1AAB5AAB6AAB9-AABDAAC0AAC2AADBAADCAAE0-AAEAAAF2AB01-AB06AB09-AB0EAB11-AB16AB20-AB26AB28-AB2EABC0-ABE2AC00-D7A3D7B0-D7C6D7CB-D7FBF900-FA6DFA70-FAD9FB1DFB1F-FB28FB2A-FB36FB38-FB3CFB3EFB40FB41FB43FB44FB46-FBB1FBD3-FD3DFD50-FD8FFD92-FDC7FDF0-FDFBFE70-FE74FE76-FEFCFF66-FF6FFF71-FF9DFFA0-FFBEFFC2-FFC7FFCA-FFCFFFD2-FFD7FFDA-FFDC",
        M: "0300-036F0483-04890591-05BD05BF05C105C205C405C505C70610-061A064B-065F067006D6-06DC06DF-06E406E706E806EA-06ED07110730-074A07A6-07B007EB-07F30816-0819081B-08230825-08270829-082D0859-085B08E4-08FE0900-0903093A-093C093E-094F0951-0957096209630981-098309BC09BE-09C409C709C809CB-09CD09D709E209E30A01-0A030A3C0A3E-0A420A470A480A4B-0A4D0A510A700A710A750A81-0A830ABC0ABE-0AC50AC7-0AC90ACB-0ACD0AE20AE30B01-0B030B3C0B3E-0B440B470B480B4B-0B4D0B560B570B620B630B820BBE-0BC20BC6-0BC80BCA-0BCD0BD70C01-0C030C3E-0C440C46-0C480C4A-0C4D0C550C560C620C630C820C830CBC0CBE-0CC40CC6-0CC80CCA-0CCD0CD50CD60CE20CE30D020D030D3E-0D440D46-0D480D4A-0D4D0D570D620D630D820D830DCA0DCF-0DD40DD60DD8-0DDF0DF20DF30E310E34-0E3A0E47-0E4E0EB10EB4-0EB90EBB0EBC0EC8-0ECD0F180F190F350F370F390F3E0F3F0F71-0F840F860F870F8D-0F970F99-0FBC0FC6102B-103E1056-1059105E-10601062-10641067-106D1071-10741082-108D108F109A-109D135D-135F1712-17141732-1734175217531772177317B4-17D317DD180B-180D18A91920-192B1930-193B19B0-19C019C819C91A17-1A1B1A55-1A5E1A60-1A7C1A7F1B00-1B041B34-1B441B6B-1B731B80-1B821BA1-1BAD1BE6-1BF31C24-1C371CD0-1CD21CD4-1CE81CED1CF2-1CF41DC0-1DE61DFC-1DFF20D0-20F02CEF-2CF12D7F2DE0-2DFF302A-302F3099309AA66F-A672A674-A67DA69FA6F0A6F1A802A806A80BA823-A827A880A881A8B4-A8C4A8E0-A8F1A926-A92DA947-A953A980-A983A9B3-A9C0AA29-AA36AA43AA4CAA4DAA7BAAB0AAB2-AAB4AAB7AAB8AABEAABFAAC1AAEB-AAEFAAF5AAF6ABE3-ABEAABECABEDFB1EFE00-FE0FFE20-FE26",
        Mn: "0300-036F0483-04870591-05BD05BF05C105C205C405C505C70610-061A064B-065F067006D6-06DC06DF-06E406E706E806EA-06ED07110730-074A07A6-07B007EB-07F30816-0819081B-08230825-08270829-082D0859-085B08E4-08FE0900-0902093A093C0941-0948094D0951-095709620963098109BC09C1-09C409CD09E209E30A010A020A3C0A410A420A470A480A4B-0A4D0A510A700A710A750A810A820ABC0AC1-0AC50AC70AC80ACD0AE20AE30B010B3C0B3F0B41-0B440B4D0B560B620B630B820BC00BCD0C3E-0C400C46-0C480C4A-0C4D0C550C560C620C630CBC0CBF0CC60CCC0CCD0CE20CE30D41-0D440D4D0D620D630DCA0DD2-0DD40DD60E310E34-0E3A0E47-0E4E0EB10EB4-0EB90EBB0EBC0EC8-0ECD0F180F190F350F370F390F71-0F7E0F80-0F840F860F870F8D-0F970F99-0FBC0FC6102D-10301032-10371039103A103D103E10581059105E-10601071-1074108210851086108D109D135D-135F1712-17141732-1734175217531772177317B417B517B7-17BD17C617C9-17D317DD180B-180D18A91920-19221927192819321939-193B1A171A181A561A58-1A5E1A601A621A65-1A6C1A73-1A7C1A7F1B00-1B031B341B36-1B3A1B3C1B421B6B-1B731B801B811BA2-1BA51BA81BA91BAB1BE61BE81BE91BED1BEF-1BF11C2C-1C331C361C371CD0-1CD21CD4-1CE01CE2-1CE81CED1CF41DC0-1DE61DFC-1DFF20D0-20DC20E120E5-20F02CEF-2CF12D7F2DE0-2DFF302A-302D3099309AA66FA674-A67DA69FA6F0A6F1A802A806A80BA825A826A8C4A8E0-A8F1A926-A92DA947-A951A980-A982A9B3A9B6-A9B9A9BCAA29-AA2EAA31AA32AA35AA36AA43AA4CAAB0AAB2-AAB4AAB7AAB8AABEAABFAAC1AAECAAEDAAF6ABE5ABE8ABEDFB1EFE00-FE0FFE20-FE26",
        Mc: "0903093B093E-09400949-094C094E094F0982098309BE-09C009C709C809CB09CC09D70A030A3E-0A400A830ABE-0AC00AC90ACB0ACC0B020B030B3E0B400B470B480B4B0B4C0B570BBE0BBF0BC10BC20BC6-0BC80BCA-0BCC0BD70C01-0C030C41-0C440C820C830CBE0CC0-0CC40CC70CC80CCA0CCB0CD50CD60D020D030D3E-0D400D46-0D480D4A-0D4C0D570D820D830DCF-0DD10DD8-0DDF0DF20DF30F3E0F3F0F7F102B102C10311038103B103C105610571062-10641067-106D108310841087-108C108F109A-109C17B617BE-17C517C717C81923-19261929-192B193019311933-193819B0-19C019C819C91A19-1A1B1A551A571A611A631A641A6D-1A721B041B351B3B1B3D-1B411B431B441B821BA11BA61BA71BAA1BAC1BAD1BE71BEA-1BEC1BEE1BF21BF31C24-1C2B1C341C351CE11CF21CF3302E302FA823A824A827A880A881A8B4-A8C3A952A953A983A9B4A9B5A9BAA9BBA9BD-A9C0AA2FAA30AA33AA34AA4DAA7BAAEBAAEEAAEFAAF5ABE3ABE4ABE6ABE7ABE9ABEAABEC",
        Me: "0488048920DD-20E020E2-20E4A670-A672",
        N: "0030-003900B200B300B900BC-00BE0660-066906F0-06F907C0-07C90966-096F09E6-09EF09F4-09F90A66-0A6F0AE6-0AEF0B66-0B6F0B72-0B770BE6-0BF20C66-0C6F0C78-0C7E0CE6-0CEF0D66-0D750E50-0E590ED0-0ED90F20-0F331040-10491090-10991369-137C16EE-16F017E0-17E917F0-17F91810-18191946-194F19D0-19DA1A80-1A891A90-1A991B50-1B591BB0-1BB91C40-1C491C50-1C5920702074-20792080-20892150-21822185-21892460-249B24EA-24FF2776-27932CFD30073021-30293038-303A3192-31953220-32293248-324F3251-325F3280-328932B1-32BFA620-A629A6E6-A6EFA830-A835A8D0-A8D9A900-A909A9D0-A9D9AA50-AA59ABF0-ABF9FF10-FF19",
        Nd: "0030-00390660-066906F0-06F907C0-07C90966-096F09E6-09EF0A66-0A6F0AE6-0AEF0B66-0B6F0BE6-0BEF0C66-0C6F0CE6-0CEF0D66-0D6F0E50-0E590ED0-0ED90F20-0F291040-10491090-109917E0-17E91810-18191946-194F19D0-19D91A80-1A891A90-1A991B50-1B591BB0-1BB91C40-1C491C50-1C59A620-A629A8D0-A8D9A900-A909A9D0-A9D9AA50-AA59ABF0-ABF9FF10-FF19",
        Nl: "16EE-16F02160-21822185-218830073021-30293038-303AA6E6-A6EF",
        No: "00B200B300B900BC-00BE09F4-09F90B72-0B770BF0-0BF20C78-0C7E0D70-0D750F2A-0F331369-137C17F0-17F919DA20702074-20792080-20892150-215F21892460-249B24EA-24FF2776-27932CFD3192-31953220-32293248-324F3251-325F3280-328932B1-32BFA830-A835",
        P: "0021-00230025-002A002C-002F003A003B003F0040005B-005D005F007B007D00A100A700AB00B600B700BB00BF037E0387055A-055F0589058A05BE05C005C305C605F305F40609060A060C060D061B061E061F066A-066D06D40700-070D07F7-07F90830-083E085E0964096509700AF00DF40E4F0E5A0E5B0F04-0F120F140F3A-0F3D0F850FD0-0FD40FD90FDA104A-104F10FB1360-13681400166D166E169B169C16EB-16ED1735173617D4-17D617D8-17DA1800-180A194419451A1E1A1F1AA0-1AA61AA8-1AAD1B5A-1B601BFC-1BFF1C3B-1C3F1C7E1C7F1CC0-1CC71CD32010-20272030-20432045-20512053-205E207D207E208D208E2329232A2768-277527C527C627E6-27EF2983-299829D8-29DB29FC29FD2CF9-2CFC2CFE2CFF2D702E00-2E2E2E30-2E3B3001-30033008-30113014-301F3030303D30A030FBA4FEA4FFA60D-A60FA673A67EA6F2-A6F7A874-A877A8CEA8CFA8F8-A8FAA92EA92FA95FA9C1-A9CDA9DEA9DFAA5C-AA5FAADEAADFAAF0AAF1ABEBFD3EFD3FFE10-FE19FE30-FE52FE54-FE61FE63FE68FE6AFE6BFF01-FF03FF05-FF0AFF0C-FF0FFF1AFF1BFF1FFF20FF3B-FF3DFF3FFF5BFF5DFF5F-FF65",
        Pd: "002D058A05BE140018062010-20152E172E1A2E3A2E3B301C303030A0FE31FE32FE58FE63FF0D",
        Ps: "0028005B007B0F3A0F3C169B201A201E2045207D208D23292768276A276C276E27702772277427C527E627E827EA27EC27EE2983298529872989298B298D298F299129932995299729D829DA29FC2E222E242E262E283008300A300C300E3010301430163018301A301DFD3EFE17FE35FE37FE39FE3BFE3DFE3FFE41FE43FE47FE59FE5BFE5DFF08FF3BFF5BFF5FFF62",
        Pe: "0029005D007D0F3B0F3D169C2046207E208E232A2769276B276D276F27712773277527C627E727E927EB27ED27EF298429862988298A298C298E2990299229942996299829D929DB29FD2E232E252E272E293009300B300D300F3011301530173019301B301E301FFD3FFE18FE36FE38FE3AFE3CFE3EFE40FE42FE44FE48FE5AFE5CFE5EFF09FF3DFF5DFF60FF63",
        Pi: "00AB2018201B201C201F20392E022E042E092E0C2E1C2E20",
        Pf: "00BB2019201D203A2E032E052E0A2E0D2E1D2E21",
        Pc: "005F203F20402054FE33FE34FE4D-FE4FFF3F",
        Po: "0021-00230025-0027002A002C002E002F003A003B003F0040005C00A100A700B600B700BF037E0387055A-055F058905C005C305C605F305F40609060A060C060D061B061E061F066A-066D06D40700-070D07F7-07F90830-083E085E0964096509700AF00DF40E4F0E5A0E5B0F04-0F120F140F850FD0-0FD40FD90FDA104A-104F10FB1360-1368166D166E16EB-16ED1735173617D4-17D617D8-17DA1800-18051807-180A194419451A1E1A1F1AA0-1AA61AA8-1AAD1B5A-1B601BFC-1BFF1C3B-1C3F1C7E1C7F1CC0-1CC71CD3201620172020-20272030-2038203B-203E2041-20432047-205120532055-205E2CF9-2CFC2CFE2CFF2D702E002E012E06-2E082E0B2E0E-2E162E182E192E1B2E1E2E1F2E2A-2E2E2E30-2E393001-3003303D30FBA4FEA4FFA60D-A60FA673A67EA6F2-A6F7A874-A877A8CEA8CFA8F8-A8FAA92EA92FA95FA9C1-A9CDA9DEA9DFAA5C-AA5FAADEAADFAAF0AAF1ABEBFE10-FE16FE19FE30FE45FE46FE49-FE4CFE50-FE52FE54-FE57FE5F-FE61FE68FE6AFE6BFF01-FF03FF05-FF07FF0AFF0CFF0EFF0FFF1AFF1BFF1FFF20FF3CFF61FF64FF65",
        S: "0024002B003C-003E005E0060007C007E00A2-00A600A800A900AC00AE-00B100B400B800D700F702C2-02C502D2-02DF02E5-02EB02ED02EF-02FF03750384038503F60482058F0606-0608060B060E060F06DE06E906FD06FE07F609F209F309FA09FB0AF10B700BF3-0BFA0C7F0D790E3F0F01-0F030F130F15-0F170F1A-0F1F0F340F360F380FBE-0FC50FC7-0FCC0FCE0FCF0FD5-0FD8109E109F1390-139917DB194019DE-19FF1B61-1B6A1B74-1B7C1FBD1FBF-1FC11FCD-1FCF1FDD-1FDF1FED-1FEF1FFD1FFE20442052207A-207C208A-208C20A0-20B9210021012103-21062108210921142116-2118211E-2123212521272129212E213A213B2140-2144214A-214D214F2190-2328232B-23F32400-24262440-244A249C-24E92500-26FF2701-27672794-27C427C7-27E527F0-29822999-29D729DC-29FB29FE-2B4C2B50-2B592CE5-2CEA2E80-2E992E9B-2EF32F00-2FD52FF0-2FFB300430123013302030363037303E303F309B309C319031913196-319F31C0-31E33200-321E322A-324732503260-327F328A-32B032C0-32FE3300-33FF4DC0-4DFFA490-A4C6A700-A716A720A721A789A78AA828-A82BA836-A839AA77-AA79FB29FBB2-FBC1FDFCFDFDFE62FE64-FE66FE69FF04FF0BFF1C-FF1EFF3EFF40FF5CFF5EFFE0-FFE6FFE8-FFEEFFFCFFFD",
        Sm: "002B003C-003E007C007E00AC00B100D700F703F60606-060820442052207A-207C208A-208C21182140-2144214B2190-2194219A219B21A021A321A621AE21CE21CF21D221D421F4-22FF2308-230B23202321237C239B-23B323DC-23E125B725C125F8-25FF266F27C0-27C427C7-27E527F0-27FF2900-29822999-29D729DC-29FB29FE-2AFF2B30-2B442B47-2B4CFB29FE62FE64-FE66FF0BFF1C-FF1EFF5CFF5EFFE2FFE9-FFEC",
        Sc: "002400A2-00A5058F060B09F209F309FB0AF10BF90E3F17DB20A0-20B9A838FDFCFE69FF04FFE0FFE1FFE5FFE6",
        Sk: "005E006000A800AF00B400B802C2-02C502D2-02DF02E5-02EB02ED02EF-02FF0375038403851FBD1FBF-1FC11FCD-1FCF1FDD-1FDF1FED-1FEF1FFD1FFE309B309CA700-A716A720A721A789A78AFBB2-FBC1FF3EFF40FFE3",
        So: "00A600A900AE00B00482060E060F06DE06E906FD06FE07F609FA0B700BF3-0BF80BFA0C7F0D790F01-0F030F130F15-0F170F1A-0F1F0F340F360F380FBE-0FC50FC7-0FCC0FCE0FCF0FD5-0FD8109E109F1390-1399194019DE-19FF1B61-1B6A1B74-1B7C210021012103-210621082109211421162117211E-2123212521272129212E213A213B214A214C214D214F2195-2199219C-219F21A121A221A421A521A7-21AD21AF-21CD21D021D121D321D5-21F32300-2307230C-231F2322-2328232B-237B237D-239A23B4-23DB23E2-23F32400-24262440-244A249C-24E92500-25B625B8-25C025C2-25F72600-266E2670-26FF2701-27672794-27BF2800-28FF2B00-2B2F2B452B462B50-2B592CE5-2CEA2E80-2E992E9B-2EF32F00-2FD52FF0-2FFB300430123013302030363037303E303F319031913196-319F31C0-31E33200-321E322A-324732503260-327F328A-32B032C0-32FE3300-33FF4DC0-4DFFA490-A4C6A828-A82BA836A837A839AA77-AA79FDFDFFE4FFE8FFEDFFEEFFFCFFFD",
        Z: "002000A01680180E2000-200A20282029202F205F3000",
        Zs: "002000A01680180E2000-200A202F205F3000",
        Zl: "2028",
        Zp: "2029",
        C: "0000-001F007F-009F00AD03780379037F-0383038B038D03A20528-05300557055805600588058B-058E059005C8-05CF05EB-05EF05F5-0605061C061D06DD070E070F074B074C07B2-07BF07FB-07FF082E082F083F085C085D085F-089F08A108AD-08E308FF097809800984098D098E0991099209A909B109B3-09B509BA09BB09C509C609C909CA09CF-09D609D8-09DB09DE09E409E509FC-0A000A040A0B-0A0E0A110A120A290A310A340A370A3A0A3B0A3D0A43-0A460A490A4A0A4E-0A500A52-0A580A5D0A5F-0A650A76-0A800A840A8E0A920AA90AB10AB40ABA0ABB0AC60ACA0ACE0ACF0AD1-0ADF0AE40AE50AF2-0B000B040B0D0B0E0B110B120B290B310B340B3A0B3B0B450B460B490B4A0B4E-0B550B58-0B5B0B5E0B640B650B78-0B810B840B8B-0B8D0B910B96-0B980B9B0B9D0BA0-0BA20BA5-0BA70BAB-0BAD0BBA-0BBD0BC3-0BC50BC90BCE0BCF0BD1-0BD60BD8-0BE50BFB-0C000C040C0D0C110C290C340C3A-0C3C0C450C490C4E-0C540C570C5A-0C5F0C640C650C70-0C770C800C810C840C8D0C910CA90CB40CBA0CBB0CC50CC90CCE-0CD40CD7-0CDD0CDF0CE40CE50CF00CF3-0D010D040D0D0D110D3B0D3C0D450D490D4F-0D560D58-0D5F0D640D650D76-0D780D800D810D840D97-0D990DB20DBC0DBE0DBF0DC7-0DC90DCB-0DCE0DD50DD70DE0-0DF10DF5-0E000E3B-0E3E0E5C-0E800E830E850E860E890E8B0E8C0E8E-0E930E980EA00EA40EA60EA80EA90EAC0EBA0EBE0EBF0EC50EC70ECE0ECF0EDA0EDB0EE0-0EFF0F480F6D-0F700F980FBD0FCD0FDB-0FFF10C610C8-10CC10CE10CF1249124E124F12571259125E125F1289128E128F12B112B612B712BF12C112C612C712D7131113161317135B135C137D-137F139A-139F13F5-13FF169D-169F16F1-16FF170D1715-171F1737-173F1754-175F176D17711774-177F17DE17DF17EA-17EF17FA-17FF180F181A-181F1878-187F18AB-18AF18F6-18FF191D-191F192C-192F193C-193F1941-1943196E196F1975-197F19AC-19AF19CA-19CF19DB-19DD1A1C1A1D1A5F1A7D1A7E1A8A-1A8F1A9A-1A9F1AAE-1AFF1B4C-1B4F1B7D-1B7F1BF4-1BFB1C38-1C3A1C4A-1C4C1C80-1CBF1CC8-1CCF1CF7-1CFF1DE7-1DFB1F161F171F1E1F1F1F461F471F4E1F4F1F581F5A1F5C1F5E1F7E1F7F1FB51FC51FD41FD51FDC1FF01FF11FF51FFF200B-200F202A-202E2060-206F20722073208F209D-209F20BA-20CF20F1-20FF218A-218F23F4-23FF2427-243F244B-245F27002B4D-2B4F2B5A-2BFF2C2F2C5F2CF4-2CF82D262D28-2D2C2D2E2D2F2D68-2D6E2D71-2D7E2D97-2D9F2DA72DAF2DB72DBF2DC72DCF2DD72DDF2E3C-2E7F2E9A2EF4-2EFF2FD6-2FEF2FFC-2FFF3040309730983100-3104312E-3130318F31BB-31BF31E4-31EF321F32FF4DB6-4DBF9FCD-9FFFA48D-A48FA4C7-A4CFA62C-A63FA698-A69EA6F8-A6FFA78FA794-A79FA7AB-A7F7A82C-A82FA83A-A83FA878-A87FA8C5-A8CDA8DA-A8DFA8FC-A8FFA954-A95EA97D-A97FA9CEA9DA-A9DDA9E0-A9FFAA37-AA3FAA4EAA4FAA5AAA5BAA7C-AA7FAAC3-AADAAAF7-AB00AB07AB08AB0FAB10AB17-AB1FAB27AB2F-ABBFABEEABEFABFA-ABFFD7A4-D7AFD7C7-D7CAD7FC-F8FFFA6EFA6FFADA-FAFFFB07-FB12FB18-FB1CFB37FB3DFB3FFB42FB45FBC2-FBD2FD40-FD4FFD90FD91FDC8-FDEFFDFEFDFFFE1A-FE1FFE27-FE2FFE53FE67FE6C-FE6FFE75FEFD-FF00FFBF-FFC1FFC8FFC9FFD0FFD1FFD8FFD9FFDD-FFDFFFE7FFEF-FFFBFFFEFFFF",
        Cc: "0000-001F007F-009F",
        Cf: "00AD0600-060406DD070F200B-200F202A-202E2060-2064206A-206FFEFFFFF9-FFFB",
        Co: "E000-F8FF",
        Cs: "D800-DFFF",
        Cn: "03780379037F-0383038B038D03A20528-05300557055805600588058B-058E059005C8-05CF05EB-05EF05F5-05FF0605061C061D070E074B074C07B2-07BF07FB-07FF082E082F083F085C085D085F-089F08A108AD-08E308FF097809800984098D098E0991099209A909B109B3-09B509BA09BB09C509C609C909CA09CF-09D609D8-09DB09DE09E409E509FC-0A000A040A0B-0A0E0A110A120A290A310A340A370A3A0A3B0A3D0A43-0A460A490A4A0A4E-0A500A52-0A580A5D0A5F-0A650A76-0A800A840A8E0A920AA90AB10AB40ABA0ABB0AC60ACA0ACE0ACF0AD1-0ADF0AE40AE50AF2-0B000B040B0D0B0E0B110B120B290B310B340B3A0B3B0B450B460B490B4A0B4E-0B550B58-0B5B0B5E0B640B650B78-0B810B840B8B-0B8D0B910B96-0B980B9B0B9D0BA0-0BA20BA5-0BA70BAB-0BAD0BBA-0BBD0BC3-0BC50BC90BCE0BCF0BD1-0BD60BD8-0BE50BFB-0C000C040C0D0C110C290C340C3A-0C3C0C450C490C4E-0C540C570C5A-0C5F0C640C650C70-0C770C800C810C840C8D0C910CA90CB40CBA0CBB0CC50CC90CCE-0CD40CD7-0CDD0CDF0CE40CE50CF00CF3-0D010D040D0D0D110D3B0D3C0D450D490D4F-0D560D58-0D5F0D640D650D76-0D780D800D810D840D97-0D990DB20DBC0DBE0DBF0DC7-0DC90DCB-0DCE0DD50DD70DE0-0DF10DF5-0E000E3B-0E3E0E5C-0E800E830E850E860E890E8B0E8C0E8E-0E930E980EA00EA40EA60EA80EA90EAC0EBA0EBE0EBF0EC50EC70ECE0ECF0EDA0EDB0EE0-0EFF0F480F6D-0F700F980FBD0FCD0FDB-0FFF10C610C8-10CC10CE10CF1249124E124F12571259125E125F1289128E128F12B112B612B712BF12C112C612C712D7131113161317135B135C137D-137F139A-139F13F5-13FF169D-169F16F1-16FF170D1715-171F1737-173F1754-175F176D17711774-177F17DE17DF17EA-17EF17FA-17FF180F181A-181F1878-187F18AB-18AF18F6-18FF191D-191F192C-192F193C-193F1941-1943196E196F1975-197F19AC-19AF19CA-19CF19DB-19DD1A1C1A1D1A5F1A7D1A7E1A8A-1A8F1A9A-1A9F1AAE-1AFF1B4C-1B4F1B7D-1B7F1BF4-1BFB1C38-1C3A1C4A-1C4C1C80-1CBF1CC8-1CCF1CF7-1CFF1DE7-1DFB1F161F171F1E1F1F1F461F471F4E1F4F1F581F5A1F5C1F5E1F7E1F7F1FB51FC51FD41FD51FDC1FF01FF11FF51FFF2065-206920722073208F209D-209F20BA-20CF20F1-20FF218A-218F23F4-23FF2427-243F244B-245F27002B4D-2B4F2B5A-2BFF2C2F2C5F2CF4-2CF82D262D28-2D2C2D2E2D2F2D68-2D6E2D71-2D7E2D97-2D9F2DA72DAF2DB72DBF2DC72DCF2DD72DDF2E3C-2E7F2E9A2EF4-2EFF2FD6-2FEF2FFC-2FFF3040309730983100-3104312E-3130318F31BB-31BF31E4-31EF321F32FF4DB6-4DBF9FCD-9FFFA48D-A48FA4C7-A4CFA62C-A63FA698-A69EA6F8-A6FFA78FA794-A79FA7AB-A7F7A82C-A82FA83A-A83FA878-A87FA8C5-A8CDA8DA-A8DFA8FC-A8FFA954-A95EA97D-A97FA9CEA9DA-A9DDA9E0-A9FFAA37-AA3FAA4EAA4FAA5AAA5BAA7C-AA7FAAC3-AADAAAF7-AB00AB07AB08AB0FAB10AB17-AB1FAB27AB2F-ABBFABEEABEFABFA-ABFFD7A4-D7AFD7C7-D7CAD7FC-D7FFFA6EFA6FFADA-FAFFFB07-FB12FB18-FB1CFB37FB3DFB3FFB42FB45FBC2-FBD2FD40-FD4FFD90FD91FDC8-FDEFFDFEFDFFFE1A-FE1FFE27-FE2FFE53FE67FE6C-FE6FFE75FEFDFEFEFF00FFBF-FFC1FFC8FFC9FFD0FFD1FFD8FFD9FFDD-FFDFFFE7FFEF-FFF8FFFEFFFF"
    });

})();
/* END Telerik.Sitefinity.Resources.Scripts.xregexp-unicode-base.js */
/* START Telerik.Sitefinity.Web.UI.Extenders.Scripts.ExpandableExtender.js */
Type.registerNamespace("Telerik.Sitefinity.Web.UI.Extenders");
Telerik.Sitefinity.Web.UI.Extenders.ExpandableExtender=function(element){this._expanded=null;
this._expandElement=null;
this._expandText=null;
this._expandTarget=null;
this._fieldControl=null;
this._originalExpandedState=false;
this._expandDelegate=null;
this._resetDelegate=null;
this._toggleDelegate=null;
this._resetSectionDelegate=null;
Telerik.Sitefinity.Web.UI.Extenders.ExpandableExtender.initializeBase(this,[element]);
};
Telerik.Sitefinity.Web.UI.Extenders.ExpandableExtender.prototype={initialize:function(){this._originalExpandedState=this._expanded;
this._expandDelegate=Function.createDelegate(this,this.expand);
this._resetDelegate=Function.createDelegate(this,this.reset);
this._toggleDelegate=Function.createDelegate(this,this.toggle);
this._resetSectionDelegate=Function.createDelegate(this,this.resetSection);
if(this._expandElement!=null){$addHandler(this._expandElement,"click",this._expandDelegate);
$addHandler(this._expandElement,"focus",this._expandDelegate);
}if(this._fieldControl!=null){if(this.isSection()){if(this._expandElement!=null){$addHandler(this._expandElement,"click",this._toggleDelegate);
}this._fieldControl.add_reset(this._resetSectionDelegate);
}else{this._fieldControl.add_reset(this._resetDelegate);
this._fieldControl.add_doExpand(this._expandDelegate);
}}Telerik.Sitefinity.Web.UI.Extenders.ExpandableExtender.callBaseMethod(this,"initialize");
},dispose:function(){if(this._expandElement){$clearHandlers(this._expandElement);
}if(this._fieldControl){if(this.isSection()){if(this._toggleDelegate){this._fieldControl.remove_doToggle(this._toggleDelegate);
}if(this._resetSectionDelegate){this._fieldControl.remove_reset(this._resetSectionDelegate);
}}else{if(this._resetDelegate){this._fieldControl.remove_reset(this._resetDelegate);
}if(this._expandDelegate){this._fieldControl.remove_doExpand(this._expandDelegate);
}}}if(this._expandDelegate){delete this._expandDelegate;
}if(this._resetDelegate){delete this._resetDelegate;
}if(this._resetSectionDelegate){delete this._resetSectionDelegate;
}if(this._toggleDelegate){delete this._toggleDelegate;
}Telerik.Sitefinity.Web.UI.Extenders.ExpandableExtender.callBaseMethod(this,"dispose");
},isSection:function(){if(Object.getTypeName(this._fieldControl)=="Telerik.Sitefinity.Web.UI.ContentUI.Views.Backend.Detail.SectionControl"){return true;
}return false;
},inheritsFieldControl:function(){if(Object.getTypeName(this._fieldControl)=="Telerik.Sitefinity.Web.UI.Fields.FieldControl"){return true;
}return false;
},expandSection:function(){var wrapper=$(this._fieldControl.get_wrapperElement());
var toggleTarget=$(this._expandTarget);
wrapper.addClass("sfExpandedForm");
toggleTarget.addClass("sfExpandedTarget");
toggleTarget.removeClass("sfCollapsedTarget");
this._fieldControl.toggle({Action:"expand"});
},collapseSection:function(){var wrapper=$(this._fieldControl.get_wrapperElement());
var toggleTarget=$(this._expandTarget);
wrapper.removeClass("sfExpandedForm");
toggleTarget.removeClass("sfExpandedTarget");
toggleTarget.addClass("sfCollapsedTarget");
this._fieldControl.toggle({Action:"collapse"});
},toggle:function(){var wrapper=$(this._fieldControl.get_wrapperElement());
wrapper.toggleClass("sfExpandedForm");
if(!wrapper.hasClass("sfExpandedForm")){this.collapseSection();
}else{this.expandSection();
}},expand:function(){this.get_expandElement().style.display="none";
this.get_expandTarget().style.display="";
if(this._fieldControl.focus){this._fieldControl.focus();
}},collapse:function(){this.get_expandElement().style.display="";
this.get_expandTarget().style.display="none";
},reset:function(){if(this._originalExpandedState){this.expand();
}else{this.collapse();
}},resetSection:function(){if(this._originalExpandedState){this.expandSection();
}else{this.collapseSection();
}},get_expanded:function(){return this._expanded;
},set_expanded:function(value){this._expanded=value;
},get_expandElement:function(){return this._expandElement;
},set_expandElement:function(value){this._expandElement=value;
},get_expandText:function(){return this._expandText;
},set_expandText:function(value){this._expandText=value;
},get_expandTarget:function(){return this._expandTarget;
},set_expandTarget:function(value){this._expandTarget=value;
},get_fieldControl:function(){return this._fieldControl;
},set_fieldControl:function(value){this._fieldControl=value;
},get_originalExpandedState:function(){return this._originalExpandedState;
}};
Telerik.Sitefinity.Web.UI.Extenders.ExpandableExtender.registerClass("Telerik.Sitefinity.Web.UI.Extenders.ExpandableExtender",Sys.UI.Behavior);

/* END Telerik.Sitefinity.Web.UI.Extenders.Scripts.ExpandableExtender.js */
/* START Telerik.Sitefinity.Web.UI.Fields.Scripts.TextField.js */
Type.registerNamespace("Telerik.Sitefinity.Web.UI.Fields");
Telerik.Sitefinity.Web.UI.Fields.TextField=function(element){Telerik.Sitefinity.Web.UI.Fields.TextField.initializeBase(this,[element]);
this._element=element;
this._labelElement=null;
this._textBoxElement=null;
this._expandableExtenderId=null;
this._expandableExtenderBehavior=null;
this._conditionalTemplatesContainerId=null;
this._templatesContainer=null;
this._hideIfValue=null;
this._suffix=null;
this._currentCondition=null;
this._textBoxId=null;
this._textLabelId=null;
this._conditionDictionary=[];
this._unit=null;
this._characterCounterElement=null;
this._recommendedCharactersCount=0;
this._trimSpaces=false;
this._maxChars=0;
this._allowNulls=false;
this._readOnlyReplacement=false;
this._readOnlyModeOriginalValue=null;
};
Telerik.Sitefinity.Web.UI.Fields.TextField.prototype={initialize:function(){Telerik.Sitefinity.Web.UI.Fields.TextField.callBaseMethod(this,"initialize");
if(this.get_displayMode()==Telerik.Sitefinity.Web.UI.Fields.FieldDisplayMode.Write){this._handleKeyDownDelegate=Function.createDelegate(this,this._keyDownHandler);
$addHandler(this.get_textElement(),"keypress",this._handleKeyDownDelegate);
this._handleKeyUpDelegate=Function.createDelegate(this,this._keyUpHandler);
$addHandler(this.get_textElement(),"keyup",this._handleKeyUpDelegate);
this._handleInputDelegate=Function.createDelegate(this,this._inputHandler);
$addHandler(this.get_textElement(),"input",this._handleInputDelegate);
this._handleFocusDelegate=Function.createDelegate(this,this._focusHandler);
$addHandler(this.get_textElement(),"focus",this._handleFocusDelegate);
this._handleBlurDelegate=Function.createDelegate(this,this._blurHandler);
$addHandler(this.get_textElement(),"blur",this._handleBlurDelegate);
}if(this._hideIfValue!=null){this.set_defaultValue(this._hideIfValue);
}this.calculateCharactersCount();
jQuery(this.get_characterCounterElement()).hide();
},dispose:function(){if(this._handleKeyDownDelegate){$removeHandler(this.get_textElement(),"keypress",this._handleKeyDownDelegate);
delete this._handleKeyDownDelegate;
}if(this._handleKeyUpDelegate){$removeHandler(this.get_textElement(),"keyup",this._handleKeyUpDelegate);
delete this._handleKeyUpDelegate;
}if(this._handleInputDelegate){$removeHandler(this.get_textElement(),"input",this._handleInputDelegate);
delete this._handleInputDelegate;
}if(this._handleFocusDelegate){$removeHandler(this.get_textElement(),"focus",this._handleFocusDelegate);
delete this._handleFocusDelegate;
}if(this._handleBlurDelegate){$removeHandler(this.get_textElement(),"blur",this._handleBlurDelegate);
delete this._handleBlurDelegate;
}this._labelElement=null;
this._textBoxElement=null;
Telerik.Sitefinity.Web.UI.Fields.TextField.callBaseMethod(this,"dispose");
},reset:function(){var defaultValue=this.get_defaultValue();
if(defaultValue==undefined){defaultValue=null;
}this.set_value(defaultValue);
jQuery(this.get_characterCounterElement()).text("");
Telerik.Sitefinity.Web.UI.Fields.TextField.callBaseMethod(this,"reset");
},get_value:function(){var val=this._get_textValue();
if(this.get_displayMode()==Telerik.Sitefinity.Web.UI.Fields.FieldDisplayMode.Write){if(val==""&&this._hideIfValue!=null){return this._hideIfValue;
}}if(val==""&&this.get_allowNulls()){return null;
}return val;
},set_value:function(value){if(this.get_trimSpaces()){value=jQuery.trim(value);
}if(this._hideIfValue!=null&&this._hideIfValue==value){if(this.get_displayMode()==Telerik.Sitefinity.Web.UI.Fields.FieldDisplayMode.Write){this._clearTextBox();
}else{this._clearLabel();
}}else{if(this.get_displayMode()==Telerik.Sitefinity.Web.UI.Fields.FieldDisplayMode.Write){this._set_writeModeValue(value);
}else{this._set_readModeValue(value);
}}this._value=value;
this.raisePropertyChanged("value");
this._valueChangedHandler();
},isChanged:function(){if(this.get_displayMode()==Telerik.Sitefinity.Web.UI.Fields.FieldDisplayMode.Write&&this._value==null){this._value="";
}var notChanged=(this._value==this.get_value());
if(notChanged){return false;
}else{return true;
}},calculateCharactersCount:function(){if(this.get_textElement().value==undefined){return;
}var currentCount=this.get_textElement().value.length;
if(currentCount==0){jQuery(this.get_characterCounterElement()).text("");
}else{jQuery(this.get_characterCounterElement()).text(currentCount);
}if(this.get_recommendedCharactersCount()!=0){this.colorCharactersCount(currentCount,this.get_recommendedCharactersCount());
}jQuery(this.get_characterCounterElement()).show();
},colorCharactersCount:function(currentCount,recommendedCount){if(currentCount<=recommendedCount){jQuery(this.get_characterCounterElement()).css("color","Black");
}else{jQuery(this.get_characterCounterElement()).css("color","Red");
}},_keyDownHandler:function(e){this.focusControlByTabKey(e);
},_inputHandler:function(e){this._trimChars();
this.calculateCharactersCount();
},_keyUpHandler:function(e){this._trimChars();
this.calculateCharactersCount();
},_focusHandler:function(e){jQuery(this.get_characterCounterElement()).show();
this.calculateCharactersCount();
},_blurHandler:function(e){if(this.get_trimSpaces()){this.get_textElement().value=jQuery.trim(this.get_value());
this.calculateCharactersCount();
}jQuery(this.get_characterCounterElement()).hide();
},_getTemplate:function(templateCondition){var templatesContainer=this._getTemplatesContainer();
var template=templatesContainer.find("#"+this._conditionDictionary[templateCondition]);
return template;
},_switchToTemplate:function(templateCondition){var currentCondition=this._currentCondition;
if(currentCondition==templateCondition){return;
}this._currentCondition=templateCondition;
var currentElement=jQuery(this._element);
var templatesContainer=this._getTemplatesContainer();
var childsExceptContainer=currentElement.children().not("#"+this._conditionalTemplatesContainerId);
var hiddenContainer=this._getTemplate(currentCondition);
if(hiddenContainer.length==0){hiddenContainerID="hiddenContainer"+this._suffix;
hiddenContainer=jQuery.find("#"+hiddenContainerID);
if(hiddenContainer.length==0){hiddenContainer=jQuery('<div id="'+hiddenContainerID+'"></div>');
}templatesContainer.append(hiddenContainer);
}childsExceptContainer.each(function(index){hiddenContainer.append(this);
});
var newTemplate=this._getTemplate(templateCondition);
var cleanHtml=jQuery.trim(newTemplate.html());
newTemplate.children().each(function(index){jQuery(this).insertBefore(templatesContainer);
});
},_getTemplatesContainer:function(){if(!this._templatesContainer){this._templatesContainer=jQuery("#"+this._conditionalTemplatesContainerId);
}return this._templatesContainer;
},_getElementFromCurrentTemplate:function(selector){return jQuery(this._element).find(selector).not("#"+this._conditionalTemplatesContainerId+" "+selector)[0];
},_buildCondition:function(left,operator,right){return String.format("{0}-{1}-{2}",left,operator,right).toLowerCase();
},_clearLabel:function(){if(this._labelElement!=null){this._labelElement.innerHTML="";
}},_clearTextBox:function(){if(this._textBoxElement!=null){this._textBoxElement.value="";
this.calculateCharactersCount();
}},_set_writeModeValue:function(value){if(value===undefined||value==null){this._clearTextBox();
}else{if(this._textBoxElement!=null){this._textBoxElement.value=value;
if(value!=this.get_defaultValue()&&jQuery("body").hasClass("sfFormDialog")){this._doExpandHandler();
}}if(this._unit!=null&&this._unit.length>0){jQuery(this._element).find("span.sfUnit").remove();
jQuery(this._textBoxElement).after('<span class="sfUnit">'+this._unit+"</span>");
}}},_set_readModeValue:function(value){this._readOnlyModeOriginalValue=value;
if(value===undefined||value==null){this._clearLabel();
}else{if(this._labelElement!=null){var resultText=null;
if(this._readOnlyReplacement){var data=JSON.parse(this._readOnlyReplacement);
if(data&&data.Value&&data.Text){var replacementCondition=data.Value==value;
var replacementText=data.Text;
if(replacementCondition&&replacementText){resultText=replacementText;
}}}if(!resultText){resultText=value;
if(this._unit!=null&&this._unit.length>0){resultText+=' <p class="sfDescription">'+this._unit+"</p>";
}}jQuery(this._labelElement).html(resultText);
}}},_get_writeModeValue:function(){if(this._textBoxElement){return this._textBoxElement.value;
}return null;
},_get_textValue:function(){if(this.get_displayMode()==Telerik.Sitefinity.Web.UI.Fields.FieldDisplayMode.Write){return this._get_writeModeValue();
}else{return this._readOnlyModeOriginalValue;
}},_get_ExpandableExtenderBehavior:function(){if(this._expandableExtenderBehavior){return this._expandableExtenderBehavior;
}this._expandableExtenderBehavior=Sys.UI.Behavior.getBehaviorByName(this._element,"ExpandableExtender");
return this._expandableExtenderBehavior;
},_trimChars:function(){if(this._maxChars&&this._maxChars>0){var value=this.get_value();
value=value.substring(0,this._maxChars);
this.set_value(value);
}},get_allowNulls:function(){return this._allowNulls;
},set_allowNulls:function(value){this._allowNulls=value;
},get_hideIfValue:function(){return this._hideIfValue;
},set_hideIfValue:function(value){this._hideIfValue=value;
},get_textBoxElement:function(){return this._textBoxElement;
},set_textBoxElement:function(value){this._textBoxElement=value;
},get_labelElement:function(){return this._labelElement;
},set_labelElement:function(value){this._labelElement=value;
},get_textElement:function(){if(this.get_displayMode()==Telerik.Sitefinity.Web.UI.Fields.FieldDisplayMode.Write){return this._textBoxElement;
}else{return this._labelElement;
}},set_displayMode:function(mode){var currentValue=this.get_value();
if(typeof mode==="string"){mode=parseInt(mode);
}this._displayMode=mode;
if(this.get_isInitialized()){switch(mode){case Telerik.Sitefinity.Web.UI.Fields.FieldDisplayMode.Read:var condition=this._buildCondition("DisplayMode","Equal","Read");
this._switchToTemplate(condition);
if(!this._labelElement){this._labelElement=this._getElementFromCurrentTemplate("#"+this._textLabelId+this.get_suffix());
}jQuery(this._labelElement).text(currentValue);
break;
case Telerik.Sitefinity.Web.UI.Fields.FieldDisplayMode.Write:var condition=this._buildCondition("DisplayMode","Equal","Write");
this._switchToTemplate(condition);
if(!this._textBoxElement){this._textBoxElement=this._getElementFromCurrentTemplate("#"+this._textBoxId+this.get_suffix());
}this._textBoxElement.value=currentValue;
break;
}}},set_tabIndex:function(value){this._tabIndex=value;
jQuery(this.get_textElement()).attr("tabindex",value);
},get_tabIndex:function(){return jQuery(this.get_textElement()).attr("tabindex");
},get_suffix:function(){return this._suffix;
},set_suffix:function(value){this._suffix=value;
},focus:function(){var input=this.get_textElement();
if(jQuery(input).is(":visible")&&jQuery(input).is(":enabled")){input.focus();
}},blur:function(){var behavior=this._get_ExpandableExtenderBehavior();
if(behavior!=null&&!behavior.get_originalExpandedState()){var val=this.get_value();
if(val==""){behavior.collapse();
}}},set_defaultValue:function(value){if(value===null||value===undefined){value="";
}this._defaultValue=value;
},get_element:function(){return this._element;
},set_element:function(value){this._element=value;
},get_conditionDictionary:function(){return this._conditionDictionary;
},set_conditionDictionary:function(value){this._conditionDictionary=value;
},get_characterCounterElement:function(){return this._characterCounterElement;
},set_characterCounterElement:function(value){this._characterCounterElement=value;
},get_recommendedCharactersCount:function(){return this._recommendedCharactersCount;
},set_recommendedCharactersCount:function(value){this._recommendedCharactersCount=value;
},get_trimSpaces:function(){return this._trimSpaces;
},set_trimSpaces:function(value){this._trimSpaces=value;
}};
Telerik.Sitefinity.Web.UI.Fields.TextField.registerClass("Telerik.Sitefinity.Web.UI.Fields.TextField",Telerik.Sitefinity.Web.UI.Fields.FieldControl);

/* END Telerik.Sitefinity.Web.UI.Fields.Scripts.TextField.js */
/* START Telerik.Sitefinity.Modules.Forms.Web.UI.Scripts.FormTextBox.js */
Type.registerNamespace("Telerik.Sitefinity.Modules.Forms.Web.UI.Fields");
Telerik.Sitefinity.Modules.Forms.Web.UI.Fields.FormTextBox=function(element){Telerik.Sitefinity.Modules.Forms.Web.UI.Fields.FormTextBox.initializeBase(this,[element]);
};
Telerik.Sitefinity.Modules.Forms.Web.UI.Fields.FormTextBox.prototype={initialize:function(){Telerik.Sitefinity.Modules.Forms.Web.UI.Fields.FormTextBox.callBaseMethod(this,"initialize");
},dispose:function(){Telerik.Sitefinity.Modules.Forms.Web.UI.Fields.FormTextBox.callBaseMethod(this,"dispose");
}};
Telerik.Sitefinity.Modules.Forms.Web.UI.Fields.FormTextBox.registerClass("Telerik.Sitefinity.Modules.Forms.Web.UI.Fields.FormTextBox",Telerik.Sitefinity.Web.UI.Fields.TextField);

/* END Telerik.Sitefinity.Modules.Forms.Web.UI.Scripts.FormTextBox.js */
/* START Telerik.Sitefinity.Modules.Forms.Web.UI.Scripts.FormParagraphTextBox.js */
Type.registerNamespace("Telerik.Sitefinity.Modules.Forms.Web.UI.Fields");
Telerik.Sitefinity.Modules.Forms.Web.UI.Fields.FormParagraphTextBox=function(element){Telerik.Sitefinity.Modules.Forms.Web.UI.Fields.FormParagraphTextBox.initializeBase(this,[element]);
};
Telerik.Sitefinity.Modules.Forms.Web.UI.Fields.FormParagraphTextBox.prototype={initialize:function(){Telerik.Sitefinity.Modules.Forms.Web.UI.Fields.FormParagraphTextBox.callBaseMethod(this,"initialize");
},dispose:function(){Telerik.Sitefinity.Modules.Forms.Web.UI.Fields.FormParagraphTextBox.callBaseMethod(this,"dispose");
}};
Telerik.Sitefinity.Modules.Forms.Web.UI.Fields.FormParagraphTextBox.registerClass("Telerik.Sitefinity.Modules.Forms.Web.UI.Fields.FormParagraphTextBox",Telerik.Sitefinity.Web.UI.Fields.TextField);

/* END Telerik.Sitefinity.Modules.Forms.Web.UI.Scripts.FormParagraphTextBox.js */
if(typeof(Sys)!=='undefined')Sys.Application.notifyScriptLoaded();
(function() {
    function loadHandler() {
        var hf = $get('ctl12_TSM');
        if (!hf) return;
        if (!hf._RSM_init) { hf._RSM_init = true; hf.value = ''; }
        hf.value += ';;Telerik.Sitefinity, Version=10.0.6412.0, Culture=neutral, PublicKeyToken=b28c218413bdf563:en-US:3eda8383-f8ae-42fd-8cf1-472a7662d4f3:3dad28d9:1900ec7d:2aeb216e:f77740f1:26cfb6dc:6e04508f:447a22b8;Telerik.Sitefinity.Resources:en-US:193470df-16c0-47af-a81b-fac6c3a0408d:c4ef6dcd:6f03d72a;Telerik.Sitefinity, Version=10.0.6412.0, Culture=neutral, PublicKeyToken=b28c218413bdf563:en-US:3eda8383-f8ae-42fd-8cf1-472a7662d4f3:8bc17194:c1fc658e:9790c5c8:ef84b30a';                                    
        Sys.Application.remove_load(loadHandler);
    };
    Sys.Application.add_load(loadHandler);
})();
