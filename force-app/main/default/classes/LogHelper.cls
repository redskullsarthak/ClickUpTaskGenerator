public with sharing class LogHelper {
    public static Boolean inprodutionornot = true; 
    public static void log(String message) {
        if (inprodutionornot || Test.isRunningTest()) {
            System.debug('[UTIL_OPPS] ' + message);
        }
    }
}