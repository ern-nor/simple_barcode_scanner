#import "FlutterBarcodeScannerPlugin.h"
#import <simple_barcode_scanner_plus/simple_barcode_scanner-Swift.h>

@implementation FlutterBarcodeScannerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterBarcodeScannerPlugin registerWithRegistrar:registrar];
}
@end
