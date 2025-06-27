PROMPTS_HISTORY.md


Well done again !

Last topic 

I saw a demo in the google ML kit where the detected barcode is highlighted in the camera preview
Though we have the barcode position information returned by rust SDK, our info is related to a single image and not to a full video flow,
But I thought you might be interested,
For your information I added the mobile_scanner project that provides the live barcode feature I mentioned in
mobile_scanner\example\lib\screens\mobile_scanner_advanced.dart

Now on a more modest approach,
I wish the flutter example app displayed the successufully decoded barcode information in the live video stream,
i.e. within the camera preview screen in an overlay (at the top of the screen, above the scanning rectangle box)
This would make a better user experience
And also it would lay the first stone of our most valuable features, i.e. in rust once the barcode is decoded use this information to call  endpoints to gather info on the products and return it directly to the app to be displayed in the overlay

These endpoints might be productInfo, productImage, productPrice, something very customizable,
But the main case does not change, data will be fetched directly from rust and passed via FFI
Do you have questions ? Shall you begin with the flutter overlay evolution ?


We want to integrate OpenFoodFact API
There is already a rust project that i added at the root openfoodfacts-rust

Please read the API documentation, especially @https://openfoodfacts.github.io/openfoodfacts-server/api/ref-barcode-normalization/ 
and this one about images @https://openfoodfacts.github.io/openfoodfacts-server/api/how-to-download-images/ 
here is the price API @https://prices.openfoodfacts.org/api/docs 
Don't bother about price yet, it is just for documentattion