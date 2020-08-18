---
---

###
 *********************************************************************************
 ** Copyright (c) 2019 Sujaykumar.Hublikar <hello@sujaykumarh.com>              **
 **                                                                             **
 ** Licensed under the Apache License, Version 2.0 (the "License")              **
 ** you may not use this file except in compliance with the License.            **
 ** You may obtain a copy of the License at                                     **
 **                                                                             **
 **       http://www.apache.org/licenses/LICENSE-2.0                            **
 **                                                                             **
 ** Unless required by applicable law or agreed to in writing, software         **
 ** distributed under the License is distributed on an "AS IS" BASIS,           **
 ** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    **
 ** See the License for the specific language governing permissions and         **
 ** limitations under the License.                                              **
 **                                                                             **
 **                                                                             **
 ** Fork it on GitHub ==>  https://github.com/Sujaykumarh                       **
 **                                                                             **
 *********************************************************************************
###

# https://coffeescript.org/#introduction

$(document).ready ->
    ## Defaults
    $('.disabled').click ->
        false

    # Page Control
    staticURL = ["/contact" , "/privacy", "/terms"]    
    
    if staticURL.indexOf(window.location.pathname) > -1
        $('.navbar').removeClass('sticky-top')

    ## For Posts page
    $('#post-page img').addClass('img-fluid')

    # Portfolio link hover
    $('.portfolio-links a .card').on 'mouseover', ->
        #$('.portfolio-links .card').not(this).stop().animate({opacity: .5}, 100)
        #$(this).stop().animate({opacity: .5}, 100)

        $(this).parent().parent().parent().find('.card').not(this).stop().animate({ opacity: .65 }, 100)
        $(this).stop().animate({opacity: 1}, 100)

    $('.portfolio-links a').on 'mouseout', ->
        $('.portfolio-links .card').stop().animate({opacity: 1}, 100)


    # add margin to top of height equal to navbar
    #$('#main-content').css('margin-top', $('nav').height() + 20 + "px" )

    # Enable tooltips
    $('[data-toggle="tooltip"]').tooltip()

    # change navbar on scroll
    $(window).scroll ->
        if staticURL.indexOf(window.location.pathname) > -1
            return

        if document.body.scrollTop > 30 || document.documentElement.scrollTop > 30
            # background
            $('nav').addClass('navBg')
            $('nav').removeClass('navNoBg')
        else
            #no background
            $('nav').addClass('navNoBg')
            $('nav').removeClass('navBg')

    #### Contact Form
    
    ## Form Reset
    $('#btnContactReset').click ->
        $('#inputName, #inputEmail, #inputMobile, #inputMessage').val('')
        $('#contactMenu').val('default')
        $('#inputName, #inputEmail, #inputMobile, #inputMessage, #contactMenu').removeClass('error is-valid is-invalid')
        $('#form-status-message').hide()
        $('#form-status-spinner').hide()
        $('#form-status-success').hide()
        $('#form-status-error').hide()
        
        false   # return false to prevent default


    ## Monitor input change
    $('.form-control').on 'input change keyup paste propertychange', ->
        $(this).removeClass('error is-valid is-invalid')

    ## Form Submit
    $('#btnContactSubmit').click ->
        # REGEX
        emailReg  = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
        nameReg   = /^\S(?!.*\s{2}).*?\S$/
        contactReg = /^(\+\d{1,3}[- ]?)?\d{10}$/

        # --- Validation
        valid = true
        
        name = $("#inputName").val()

        email = $("#inputEmail").val().toLowerCase()

        message = $("#inputMessage").val()

        mobileNumber = $("#inputMobile").val()

        contactMenu = $("#contactMenu").val()

        # --- Contact Name
        if name == ""
            valid = false
            $("#inputName").addClass('error is-invalid')
        else
            if nameReg.test(name)
                $("#inputName").removeClass('error is-invalid')
                $("#inputName").addClass('is-valid')
            else
                valid = false
                $("#inputName").addClass('error is-invalid')

        # --- Contact Email
        if email == ""
            valid = false
            $("#inputEmail").addClass('error is-invalid')
        else
            if emailReg.test(email)
                $("#inputEmail").removeClass('error is-invalid')
                $("#inputEmail").addClass('is-valid')
            else
                valid = false
                $("#inputEmail").addClass('error is-invalid')


        # --- Contact Message
        if message == ""
            valid = false
            $("#inputMessage").addClass('error is-invalid')
        else
            $("#inputMessage").removeClass('error is-invalid')
            $("#inputMessage").addClass('is-valid')

        # --- Contact Menu Option
        if contactMenu == "default"
            valid = false
            $("#contactMenu").addClass('error is-invalid')
        else
            $("#contactMenu").removeClass('error is-invalid')
            $("#contactMenu").addClass('is-valid')


        # --- Contact number
        if mobileNumber == ""
            valid = false
            $("#inputMobile").addClass('error is-invalid')
        else
            mobileNumber = mobileNumber.trim()
            if contactReg.test(mobileNumber)
                $("#inputMobile").removeClass('error is-invalid')
                $("#inputMobile").addClass('is-valid')
            else
                valid = false
                $("#inputMobile").addClass('error is-invalid')


        

        # --- Check Valid form
        #if !valid
        #    console.log("Invalid Form")

        if valid
            $('#form-status-message').hide()
            $('#btnContactSubmit, #btnContactReset, #inputName, #inputEmail, #inputMobile, #inputMessage, #contactMenu').attr('disabled', '')
            $('#form-status-spinner').show()
            $('#form-status-success').hide()
            $('#form-status-error').hide()

            # +++  SUBMIT FORM
            postURL = "https://formspree.io/sujaykumar6390@gmail.com";
            postData = {
                name : name,
                email : email,
                contactNumber : mobileNumber,
                topic : contactMenu,
                message : message
            }
            $.ajax
                url : postURL
                method : "POST"
                data : postData,
                dataType : "json"
                success : ->
                    $('#form-status-spinner').hide()
                    $('#form-status-success').show()
                    $('#btnContactSubmit, #btnContactReset, #inputName, #inputEmail, #inputMobile, #inputMessage, #contactMenu').removeAttr('disabled')
                    console.log "SUCCESS"
                error : (e) ->
                    $('#form-status-spinner').hide()
                    $('#form-status-error').show()
                    $('#btnContactSubmit, #btnContactReset, #inputName, #inputEmail, #inputMobile, #inputMessage, #contactMenu').removeAttr('disabled')
                    console.log "ERROR"
                    console.log e


        false   # return false to prevent default