public class ClickUpTaskForOpportunity implements Queueable, Database.AllowsCallouts {
    private List<Opportunity> oppList;
    private String workspaceName;
    private String spaceName;
    private String listName;
    public ClickUpTaskForOpportunity(List<Opportunity> oppList, String workspaceName, String spaceName, String listName) {
        this.oppList = oppList;
        this.workspaceName = workspaceName;
        this.spaceName = spaceName;
        this.listName = listName;
    }
    public void execute(QueueableContext context) {
        try {
            UtilsForOppsClickUp utils = new UtilsForOppsClickUp(oppList, workspaceName, spaceName, listName);
            utils.mainGenerator();
        } catch (Exception e) {
            System.debug('Error in ClickUpTaskForOpportunity Queueable: ' + e.getMessage());
        }
    }
}