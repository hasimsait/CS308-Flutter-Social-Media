import 'dart:convert';
import 'dart:io';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:http/http.dart' as http;
import 'package:teamone_social_media/helper/session.dart';
import 'constants.dart';
import 'package:teamone_social_media/post.dart';
import 'package:teamone_social_media/user.dart';

class Requests {
  static String token;
  static Map<String, String> header;
  static String currUserName;

  Future<String> auth(LoginData data) async {
    if (Constants.DEPLOYED) {
      var response = await http.post(
        Constants.backendURL + Constants.signInEndpoint,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': data.name,
          'password': data.password,
        }),
      );
      if (response.statusCode >= 400 || response.statusCode < 100)
        return json.decode(response.body)["message"];
      Session sessionToken =
          Session(id: 0, data: json.decode(response.body)["data"]["token"]);
      await FlutterSession().set('sessionToken', sessionToken);
      Session userName =
          Session(id: 1, data: json.decode(response.body)["data"]["userName"]);
      await FlutterSession().set('userName', userName);
      token = json.decode(response.body)["data"]["token"];
      header = {
        'Content-Type': 'application/json; charset=UTF-8',
        'currentUser': jsonEncode(<String, String>{'token': token})
      };
      currUserName = data.name;
      return null;
    } else {
      Session sessionToken =
          Session(id: 0, data: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
      await FlutterSession().set('sessionToken', sessionToken);
      Session userName = Session(id: 1, data: data.name);
      await FlutterSession().set('userName', userName);
      token = "MYSTATICTOKEN";
      header = {
        'Content-Type': 'application/json; charset=UTF-8',
        'currentUser': jsonEncode(<String, String>{'token': token})
      };
      currUserName = data.name;
      return null;
    }
  }

  Future<String> signupUser(LoginData data) {
    //TODO modify this function for whatever they did in the backend
    return null; //
  }

  Future<String> recoverPassword(String name) {
    //this feature hasn't been implemented yet, also not in acceptance criteria
    return null;
  }

  Future<bool> updateUserInfo(String newName, File newPP) async {
    //TODO get selected Image, turn it into string and post the request to change user info, if response is succes, setstate and pop.
    if (!Constants.DEPLOYED)
      return true;
    //the part below depends on how the edit works in the backend. worst case we create an user instance getInfo then set the fields to those and send that.
    else {
      if (newPP != null) {
        String imageAsString = base64Encode(newPP.readAsBytesSync());
      }
      if (newName != null && newPP == null) {
        //set myName = newName;
      } else if (newName == "" && newPP != null) {
        //set pp to newPP;
      } else if (newName != null && newPP != null) {
        //set myName = newName;
        //set pp to newPP;
      }
    }
  }

  Future<bool> postComment(String text, int postID, currUserName) async {
    if (Constants.DEPLOYED) {
      //TODO send the request to comment to postID
      //if successful return true, else return false.
    } else {
      return true;
    }
  }

  Future<Post> reloadPost(int postID, {Post oldPost}) async {
    //TODO remove oldPost from parameters.
    if (Constants.DEPLOYED || oldPost == null) {
      //TODO request the post from the server (this method is called when user edits the post or a comment is posted under the post.)
      //if instagram can get away with doing this, we can too.
    } else {
      var newComm;
      if (oldPost.postComments != null) {
        newComm = Map<String, String>.from(oldPost.postComments);
        newComm.addAll({"reload the feed": "to see your comment"});
      } else
        newComm = {"if deployed was set to true": "the post would reload"};
      var newPost = oldPost.from();
      newPost.postComments = newComm;
      return newPost;
    }
  }

  Future<bool> sendPost(Post myPost) async {
    if (Constants.DEPLOYED) {
      dynamic userName = await FlutterSession().get('userName');
      var response = await http.post(
        Constants.backendURL + Constants.createPostEndpoint,
        headers: header,
        body: jsonEncode(<String, String>{
          'postOwnerName': userName,
          'postText': myPost.text == null ? "" : myPost.text,
          'postImage': (myPost.image == null) ? null : myPost.image,
          'postTopic': myPost.topic,
          'postVideoURL': (myPost.videoURL == null) ? null : myPost.videoURL,
          'postGeoName':
              myPost.placeName == null ? null : myPost.placeName.toString(),
          'postGeoID':
              myPost.placeGeoID == null ? null : myPost.placeGeoID.toString(),
        }),
      );
      if (response.statusCode < 400 && response.statusCode >= 200) {
        return true;
      } else {
        return false;
      }
    } else {
      print(Constants.backendURL + Constants.createPostEndpoint);
      return true;
    }
  }

  Future<bool> editPost(Post myPost) async {
    if (Constants.DEPLOYED) {
      dynamic userName = await FlutterSession().get('userName');
      var response = await http.post(
        Constants.backendURL +
            Constants.editPostEndpoint +
            myPost.postID.toString(), //api/v1/posts/edit/postID
        headers: header,
        body: jsonEncode(<String, String>{
          'postOwnerName':
              userName, //I could do myPost.postOwnerName but this seems like a better idea
          'postText': myPost.text == null ? "" : myPost.text,
          'postImage': (myPost.image == null) ? null : myPost.image,
          'postTopic': myPost.topic,
          'postVideoURL': (myPost.videoURL == null) ? null : myPost.videoURL,
          'postGeoName':
              myPost.placeName == null ? null : myPost.placeName.toString(),
          'postGeoID':
              myPost.placeGeoID == null ? null : myPost.placeGeoID.toString(),
        }),
      );
      if (response.statusCode < 400 && response.statusCode >= 200) {
        return true;
      } else {
        return false;
      }
    } else {
      print(Constants.backendURL +
          Constants.editPostEndpoint +
          myPost.postID.toString());
      return true;
    }
  }

  Future<bool> deletePost(int postID) async {
    if (Constants.DEPLOYED) {
      var response = await http.post(
        Constants.backendURL + Constants.deletePostEndpoint + postID.toString(),
        headers: header,
      ); //TODO make sure it is a get request
      if (response.statusCode < 400 && response.statusCode >= 200) {
        return true;
      } else {
        return false;
      }
    } else {
      print(Constants.backendURL +
          Constants.deletePostEndpoint +
          postID.toString());
      return true;
    }
  }

  Future<Map<int, Post>> getPosts(String userName, String s) async {
    if (Constants.DEPLOYED) {
      if (s == 'feed') {
        //request feed of userName
      } else if (s == 'posts') {
        //retrieve posts by userName
      }
      //parse the response som it looks like the static map below.
    } else {
      if (s == 'feed') {
        return new Map<int, Post>.from({
          0: new Post(
              text: "This is a sample post with an image and a location.",
              placeName: "Sample Place Name",
              postDate: DateTime.now(),
              image: Constants.sampleProfilePictureBASE64,
              postID: 0,
              postLikes: 0,
              postDislikes: 10,
              postOwnerName: "hasimsait",
              postComments: {
                "ahmet": "sample comment",
                "mehmet": "lorem ipsum..."
              }),
          1: new Post(
              text: "This is another sample post under a topic.",
              postDate: DateTime.now(),
              postID: 1,
              topic: "Sample Topic",
              postLikes: 10,
              postDislikes: 0,
              postOwnerName: "hasimsait"),
          2: new Post(
              text:
                  "This is a post from another user. Name and image are static, don't mind them.",
              postDate: DateTime.now(),
              postID: 2,
              postLikes: 100,
              postDislikes: 10,
              postOwnerName: "aaaaaa",
              postComments: {
                "ayşe": "sample comment",
                "ĞĞĞĞĞ": "lorem ipsum...",
                'aaaaaaaaaaaa': 'aaaaaaaaaaaaaaaaaaaaaa'
              }),
        });
      } else if (s == 'posts') {
        User profileOwner = User(userName);
        profileOwner.getInfo();
        return new Map<int, Post>.from({
          0: new Post(
              text: "This is a sample post with an image and a location.",
              placeName: "Sample Place Name",
              postDate: DateTime.now(),
              image: Constants.sampleProfilePictureBASE64,
              postID: 0,
              postLikes: 0,
              postDislikes: 10,
              postOwnerName: userName,
              postComments: {
                "ahmet": "sample comment",
                "mehmet": "lorem ipsum..."
              }),
          1: new Post(
              text: "This is another sample post under a topic.",
              postDate: DateTime.now(),
              postID: 1,
              topic: "Sample Topic",
              postLikes: 10,
              postDislikes: 0,
              postOwnerName: userName),
          2: new Post(
              text:
                  "This is a post from another user. Name and image are static, don't mind them.",
              postDate: DateTime.now(),
              postID: 2,
              postLikes: 100,
              postDislikes: 10,
              postOwnerName: userName,
              postComments: {
                "ayşe": "sample comment",
                "ĞĞĞĞĞ": "lorem ipsum...",
                'aaaaaaaaaaaa': 'aaaaaaaaaaaaaaaaaaaaaa'
              }),
        });
      }
    }
  }

  Future<User> getUserInfo(String userName) async {
    //TODO use the search thing here (returns profile page dto) add the is following attribute too, really important
  }

  Future<bool> followTopic(String topic) async {
    if (Constants.DEPLOYED) {
    } else {
      return true;
    }
  }

  Future<bool> unfollowTopic(String topic) async {
    if (Constants.DEPLOYED) {
    } else {
      return true;
    }
  }

  Future<bool> followLocation(String locationID) async {
    if (Constants.DEPLOYED) {
    } else {
      return true;
    }
  }

  Future<bool> unfollowLocation(String locationID) async {
    if (Constants.DEPLOYED) {
    } else {
      return true;
    }
  }

  Future<bool> isFollowingTopic(String topic) async {
    if (Constants.DEPLOYED) {
    } else {
      return true;
    }
  }

  Future<bool> isFollowingLocation(String locationID) async {
    if (Constants.DEPLOYED) {
    } else {
      return true;
    }
  }

  Future<bool> deleteAcccount() async {
    return true;
  }

  Future<bool> like(int postID) async {
    //this feature hasn't been implemented yet (I guess, either that or not in documentation), not in their acceptance criteria
    //return true if successful
    if (Constants.DEPLOYED) {
    } else {
      return true;
    }
  }
  Future<bool> dislike(int postID) async {
    //this feature hasn't been implemented yet (I guess, either that or not in documentation), not in their acceptance criteria
    //return true if successfull
    if (Constants.DEPLOYED) {
    } else {
      return true;
    }
  }
}
