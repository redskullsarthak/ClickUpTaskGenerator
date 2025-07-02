// public class ClickUpTaskForOpportunity implements Queueable, Database.AllowsCallouts {
//     private List<Opportunity> oppList;
//     private String workspaceName;
//     private String spaceName;
//     private String listName;
//     public ClickUpTaskForOpportunity(List<Opportunity> oppList) {
//         this.oppList = oppList;
//         //, String workspaceName, String spaceName, String listName
//         // this.workspaceName = workspaceName;
//         // this.spaceName = spaceName;
//         // this.listName = listName;
//     }
//     public void execute(QueueableContext context) {
//         try {
//             // UtilsForOppsClickUp utils = new UtilsForOppsClickUp(oppList, workspaceName, spaceName, listName);
//             // utils.mainGenerator();
//             for(Opportunity opp : oppList){
//                 UtilsForOpps2= new UtilsForOpps2(opp);
//                 utilsForOpps2.mainGenerator();
//             }
//         } catch (Exception e) {
//             System.debug('Error in ClickUpTaskForOpportunity Queueable: ' + e.getMessage());
//         }
//     }
// }

public class ClickUpTaskForOpportunity implements Queueable, Database.AllowsCallouts {
    public static List<Opportunity> oppList2=new List<Opportunity>(); // for testing added this 
    private List<Opportunity> oppList;
    public ClickUpTaskForOpportunity(List<Opportunity> oppList) {
        this.oppList = oppList;
    }
    public void execute(QueueableContext context) {
        for (Opportunity opp : oppList) {
            String ws = opp.Workspace__c;
            String space = opp.Space__c;
            String ls = opp.List__c;
            oppList2.add(opp);
            UtilsForOpps2 utils = new UtilsForOpps2(opp, ws, space, ls);
            utils.mainGenerator();
        }
    }
}