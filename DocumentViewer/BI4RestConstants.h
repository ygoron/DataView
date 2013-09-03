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

#define rootFolderChildrenPoint @"/infostore/Root Folder/children"
#define rootFolderPoint @"/infostore/Root Folder"

#define infoStorePoint @"/infostore/"

#define userFoldersChildrenPoint @"/infostore/User Folders/children"
#define userFoldersPoint @"/infostore/User Folders"

#define inboxesChildrenPoint @"/infostore/Inboxes/children"
#define inboxesPoint @"/infostore/Inboxes"

#define personalCategoriesChildrenPoint @"/infostore/Personal Categories/children"
#define personalCategoriesPoint @"/infostore/Personal Categories"

#define categoriesPoint @"/infostore/Categories"
#define categoriesChildrenPoint @"/infostore/Categories/children"

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
