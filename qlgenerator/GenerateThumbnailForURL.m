#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#include "DDS/dds.h"

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    DDS *dds = [DDS ddsWithURL: (NSURL*) url];
    if (!dds || QLThumbnailRequestIsCancelled(thumbnail))
    {
        [pool release];
        return kQLReturnNoError;
    }

    CGImageRef image = [dds CreateImageWithPreferredWidth:maxSize.width andPreferredHeight:maxSize.height];   // use a lower-level mipmap
    if (!image || QLThumbnailRequestIsCancelled(thumbnail))
    {
        if (image)
            CGImageRelease(image);
        [pool release];
        return kQLReturnNoError;
    }

    /* Add a "DDS" stamp if the thumbnail is not too small */
    NSDictionary *properties = (maxSize.height > 16 ?
                                [NSDictionary dictionaryWithObject:@"DDS" forKey:(NSString *) kQLThumbnailPropertyExtensionKey] :
                                NULL);
    QLThumbnailRequestSetImage(thumbnail, image, (CFDictionaryRef) properties);

    CGImageRelease(image);

    [pool release];
    return kQLReturnNoError;
}

void CancelThumbnailGeneration(void* thisInterface, QLThumbnailRequestRef thumbnail)
{
    // implement only if supported
}