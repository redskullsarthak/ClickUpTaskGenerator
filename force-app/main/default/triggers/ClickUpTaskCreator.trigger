trigger ClickUpTaskCreator on Case (after insert) {
    set<Id> st=new set<Id>();
    for(case c: trigger.new){
        st.add(c.Id);
    }
    ClickUpTask.generateTasks(st);     
}