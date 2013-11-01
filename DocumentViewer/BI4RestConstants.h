//
//  BI4RestConstants.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-20.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BI4RestConstants : NSObject

#define AUTH_ENTERPRISE @"secEnterprise"
#define AUTH_WINAD @"secWinAD"
#define AUTH_LDAP @"secLDAP"
#define cypressSDKPoint_Default @"/biprws"
#define webiRestSDKPoint_Default @"/biprws/raylight/v1"
#define mobileServiceBase @"/MobileBIService/MessageHandlerServlet"
#define mobileServicePort 8080

#define logonPathPoint @"/logon/long"
#define logoffPathPoint @"/logoff"

//#define rootFolderChildrenPoint @"/infostore/Root Folder/children"
//#define rootFolderPoint @"/infostore/Root Folder"

#define rootFolderChildrenPoint @"/infostore/cuid_ASHnC0S_Pw5LhKFbZ.iA_j4/children"
#define rootFolderPoint @"/infostore/cuid_ASHnC0S_Pw5LhKFbZ.iA_j4"

#define infoStorePoint @"/infostore/"

//#define userFoldersChildrenPoint @"/infostore/User Folders/children"
//#define userFoldersPoint @"/infostore/User Folders"

#define userFoldersChildrenPoint @"/infostore/cuid_AWigQI18AAZJoXfRHLzWJ2c/children"
#define userFoldersPoint @"/infostore/cuid_AWigQI18AAZJoXfRHLzWJ2c"


//#define inboxesChildrenPoint @"/infostore/Inboxes/children"
//#define inboxesPoint @"/infostore/Inboxes"

#define inboxesChildrenPoint @"/infostore/cuid_AVmJiqdOvoRBoU1vQCZydFE/children"
#define inboxesPoint @"/infostore/cuid_AVmJiqdOvoRBoU1vQCZydFE"



//#define personalCategoriesChildrenPoint @"/infostore/Personal Categories/children"
//#define personalCategoriesPoint @"/infostore/Personal Categories"

#define personalCategoriesChildrenPoint @"/infostore/cuid_ATI2BcB9RGBFuBi5s1TwL7k/children"
#define personalCategoriesPoint @"/infostore/cuid_ATI2BcB9RGBFuBi5s1TwL7k"


//#define categoriesPoint @"/infostore/Categories"
//#define categoriesChildrenPoint @"/infostore/Categories/children"



#define categoriesPoint @"/infostore/cuid_AaIf8uqN5AZAn7jke7q8ffw"
#define categoriesChildrenPoint @"/infostore/cuid_AaIf8uqN5AZAn7jke7q8ffw/children"


#define getDocumentsPathPoint @"/documents"
#define getUniversesPathPoint @"/universes"

#define HEADER_SAP_OFFSET @"offset"
#define HEADER_SAP_LIMIT @"limit"
#define BOXI_TOKEN_ERROR @"Not a valid logon token. (FWB 00003)\n"
//#define BOXI_TOKEN_ERROR_2 @"The argument has an invalid value token (FWM 02024)"
#define MAX_DISPLAY_HTTP_STRING 100
//#define MAX_DOCUMENTS_INT 30


#define JSON_RESP_TOKEN @"logonToken"
#define JSON_RESP_ERROR_MESSAGE @"message"
#define JSON_RESP_ERROR_CODE @"error_code"


#define SAP_HTTP_TOKEN @"X-SAP-LogonToken"

@end
