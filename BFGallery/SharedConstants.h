//
//  SharedConstants.h
//  lerandomme
//
//  Created by Dario Lencina on 5/19/12.
//  Copyright (c) 2012 Dario Lencina. All rights reserved.
//

#ifndef lerandomme_SharedConstants_h
#define lerandomme_SharedConstants_h

#define OBJECTIVE_FLICKR_API_KEY @"2d3ef1e69f5909f748d29655dab13745"
#define OBJECTIVE_FLICKR_SHARED_SECRET @"FLIa2c1da14aba1815d"
#define flickrSearchMethodString  @"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=%@&per_page=50&format=json&nojsoncallback=1&page=%d"
#define littleImagesURLFormat @"http://farm%@.static.flickr.com/%@/%@_%@_s.jpg"
#define mediumImagesURLFormat @"http://farm%@.static.flickr.com/%@/%@_%@_b.jpg"

#endif
