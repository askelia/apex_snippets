/*
Snippet to find which SObjects have a specified field.
Sometimes a managed trigger raises an exception and the error messages indicates the field name but not the SObject Name : 

      blng.OrderItemConsumptionScheduleTrigger: 
      execution of AfterInsert caused by: System.DmlException: Insert failed. 
      First exception on row 0; first error: 
      INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST, Unit Of Measure: bad value for restricted picklist field: Micron: [blng__UnitOfMeasure__c] (blng)

The field here is blng__UnitOfMeasure__c but how do you know what SObject the trigger was trying to insert ? 

*/

String searchedField = 'blng__UnitOfMeasure__c';                //the name of the field you search
List<String> sObjList = new List<String>();                     //the SObjects that have such a field
Map<String, SObjectType> sObjMap = schema.getGlobalDescribe();      //get all SObjects
for (String sObjName : sObjMap.keyset()){
    for(String field :  sObjMap.get(sObjName).getDescribe().fields.getMap().keySet()){    //get all fields for each SObject
        if (searchedField.equalsIgnoreCase(field)) {                                      //compare name to your search
            sObjList.add(sObjMap.get(sObjName).getDescribe().getLabel());                 //if it matches add it to the list
        }
      }    
}
System.debug(sObjList);     //display the list

//Check logs in developer console, click 'Debug Only'
