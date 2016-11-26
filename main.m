#import "BMAppDelegate.h"

int main(int argc, char *argv[]) {
    @autoreleasepool {
        setuid(0);
        setgid(0);
        return UIApplicationMain(argc, argv, nil, NSStringFromClass(BMAppDelegate.class));
    }
}
