/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestOppUtils {
    @isTest static void testTrigger() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ClickUpMockCallout());
        ClickUpTaskForOpportunity.oppList2 = new List<Opportunity>();
        Opportunity opp = new Opportunity( Name = 'Test Opp',StageName = 'Prospecting',CloseDate = Date.today().addDays(10),Workspace__c = 'CRM Testing Workspace',Space__c = 'Team Space',List__c = 'Salesforce Tasks');
        insert opp;
        opp.StageName = 'Closed Lost';
        update opp;
        Test.stopTest();
        System.assertEquals(1, ClickUpTaskForOpportunity.oppList2.size());
        System.assertEquals('Closed Lost', [SELECT StageName FROM Opportunity WHERE Id = :opp.Id].StageName);
    }   
    // trigger test shows 100percent
    @isTest static void testQueueable(){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ClickUpMockCallout());
            ClickUpTaskForOpportunity.oppList2.clear();
            Opportunity opp = new Opportunity( Name = 'Test Opp',StageName = 'Prospecting',CloseDate = Date.today().addDays(10),Workspace__c = 'CRM Testing Workspace',Space__c = 'Team Space',List__c = 'Salesforce Tasks');
            insert opp;
            opp.StageName='Closed Lost';
            update opp;
            Test.stopTest();
            System.assertEquals(1, ClickUpTaskForOpportunity.oppList2.size());
            System.assertEquals(ClickUpTaskForOpportunity.oppList2[0],opp);
    }
    // test shows 100 coverage 
    // test each function seperately otherwise it will be very long 

    // check constructor first 
    @isTest static void testUtils(){
       Test.startTest();
       Opportunity opp = new Opportunity( Name = 'Test Opp',CloseDate = Date.today().addDays(10),Workspace__c = 'CRM Testing Workspace',Space__c = 'Team Space',List__c = 'Salesforce Tasks',StageName='Closed Lost');
       String ws='CRM Testing Workspace';
       String sn='Team Space';
       String ln='Salesforce Tasks';
       UtilsForOpps2 c = new UtilsForOpps2(opp,ws,sn,ln);
       // check if constructor is working ?
       System.assertEquals(c.oppList,opp);
       System.assertEquals(c.WorkspaceName,ws);
       System.AssertEquals(c.SpaceName,sn);
       System.AssertEquals(c.ListName,ln);
       Test.stopTest();
    }

    // check for resGeneratot
    @isTest static void testResgen(){
        Test.startTest();
        Opportunity opp = new Opportunity( Name = 'Test Opp',CloseDate = Date.today().addDays(10),Workspace__c = 'CRM Testing Workspace',Space__c = 'Team Space',List__c = 'Salesforce Tasks',StageName='Closed Lost');
        String ws='CRM Testing Workspace';
        String sn='Team Space';
        String ln='Salesforce Tasks';
        UtilsForOpps2 c = new UtilsForOpps2(opp,ws,sn,ln);

        String mockCallres='{"teams": [{"id": "team123", "name": "CRM Testing Workspace"}]}';
        httpResponse hres=c.resGenerator('/team','','');
        System.AssertEquals(hres.getBody(),mockCallres);
        Test.stopTest();
    }


@isTest static void testpostTask() {
    Test.setMock(HttpCalloutMock.class, new ClickUpMockCallout());

    Opportunity opp = new Opportunity(
        Name = 'Test Opp',
        StageName = 'Prospecting',
        CloseDate = Date.today().addDays(10),
        Workspace__c = 'CRM Testing Workspace',
        Space__c = 'Team Space',
        List__c = 'Salesforce Tasks'
    );

    UtilsForOpps2 utils = new UtilsForOpps2(opp, opp.Workspace__c, opp.Space__c, opp.List__c);

    Test.startTest();
    HttpResponse res = utils.postTask('list123');
    Test.stopTest();

    System.assertEquals('{"id": "task123", "name": "Created Task"}', res.getBody());
}
    


    @isTest
    static void testMainGenerator() {
       Test.setMock(HttpCalloutMock.class, new ClickUpMockCallout());

       Opportunity opp = new Opportunity(
          Name = 'Test Opp',
        StageName = 'Closed Lost',
        CloseDate = Date.today().addDays(10),
        Workspace__c = 'CRM Testing Workspace',
        Space__c = 'Team Space',
        List__c = 'Salesforce Tasks'
       );
        UtilsForOpps2 utils = new UtilsForOpps2(opp, opp.Workspace__c, opp.Space__c, opp.List__c);

        Test.startTest();
        utils.mainGenerator();
        Test.stopTest();
       System.assertEquals('Test Opp', utils.oppList.Name);
    }
    
        @isTest
       static void testIdGetter() {
        String mockJson = '{"teams": ['+ '{"id": "team123", "name": "CRM Testing Workspace"},'+ '{"id": "team456", "name": "Another Workspace"}'+ ']}';
       HttpResponse res = new HttpResponse();
       res.setBody(mockJson);
       res.setStatusCode(200);
        Opportunity opp = new Opportunity( Name = 'Test Opp',CloseDate = Date.today().addDays(10),Workspace__c = 'CRM Testing Workspace',Space__c = 'Team Space',List__c = 'Salesforce Tasks',StageName='Closed Lost');
       UtilsForOpps2 utils = new UtilsForOpps2(null, null, null, null);
       String result = utils.idGetter(res, 'teams', 'id', 'CRM Testing Workspace');
       System.assertEquals('team123', result);
       String result2 = utils.idGetter(res, 'teams', 'id','random thing which does not exist');// workspace/list/space is not there 
       System.assertEquals(null, result2);
    }
}