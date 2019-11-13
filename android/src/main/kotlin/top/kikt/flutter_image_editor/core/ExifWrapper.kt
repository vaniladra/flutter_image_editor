package top.kikt.flutter_image_editor.core

import android.content.Context
import androidx.exifinterface.media.ExifInterface
import java.io.File
import java.io.InputStream

/// create 2019-11-13 by cai
class ExifWrapper(private val oldExif: ExifInterface) {
  
  companion object {
    val attributes = listOf(
      "FNumber",
      "ExposureTime",
      "ISOSpeedRatings",
      "GPSAltitude",
      "GPSAltitudeRef",
      "FocalLength",
      "GPSDateStamp",
      "WhiteBalance",
      "GPSProcessingMethod",
      "GPSTimeStamp",
      "DateTime",
      "Flash",
      "GPSLatitude",
      "GPSLatitudeRef",
      "GPSLongitude",
      "GPSLongitudeRef",
      "Make",
      "Model",
      "Orientation")
    
    fun createWrapper(inputStream: InputStream): ExifWrapper {
      return ExifInterface(inputStream).toWrapper()
    }
    
    fun createWrapper(file: File): ExifWrapper {
      file.inputStream().use {
        return@createWrapper createWrapper(it)
      }
    }
    
    private fun ExifInterface.toWrapper(): ExifWrapper {
      return ExifWrapper(this)
    }
    
    private fun setIfNotNull(oldExif: ExifInterface, newExif: ExifInterface, property: String) {
      if (oldExif.getAttribute(property) != null) {
        newExif.setAttribute(property, oldExif.getAttribute(property))
      }
    }
  }
  
  fun saveTo(context: Context, byteArray: ByteArray): ByteArray {
    val tmpFile = File(context.cacheDir, "${System.currentTimeMillis()}.jpg")
    tmpFile.writeBytes(byteArray)
    val newExif = tmpFile.inputStream()
      .let {
        it.use {
          ExifInterface(it)
        }
      }
    
    for (attribute in attributes) {
      setIfNotNull(oldExif, newExif, attribute)
    }
    newExif.saveAttributes()
    
    val result = tmpFile.readBytes()
    tmpFile.delete()
    return result
  }
  
  fun saveTo( filePath: String) {
    val tmpFile = File(filePath)
    
    val newExif = tmpFile.inputStream()
      .let {
        it.use {
          ExifInterface(it)
        }
      }
    
    for (attribute in attributes) {
      setIfNotNull(oldExif, newExif, attribute)
    }
    newExif.saveAttributes()
  }
  
}