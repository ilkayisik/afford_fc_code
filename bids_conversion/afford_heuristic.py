import os

def create_key(template, outtype=('nii.gz','dicom'), annotation_classes=None):
    if template is None or not template:
        raise ValueError('Template must be a valid format string')
    return (template, outtype, annotation_classes)


def infotodict(seqinfo):
    """Heuristic evaluator for determining which runs belong where
    allowed template fields - follow python string module:
    item: index within category
    subject: participant id
    seqitem: run number during scanning
    subindex: sub index within group
    """
    """
    Create run names following this format:
    func/sub-<participant_label>_task-<task_label>[_acq-<label>][_rec-<label>]
    [_run-<index>]_bold.nii[.gz]
    fmap/sub-<participant_label>[_acq-<label>]_dir-<dir_label>[_run-
      <run_index>]_epi.nii[.gz]
    """
    # Anatomicals
    t1 = create_key('anat/sub-{subject}_T1w')

    # Functional
    afford = create_key('func/sub-{subject}_task-afford_run-{item:02d}_bold')
    # Functional (rest)
    rest = create_key('func/sub-{subject}_task-rest_run-{item:02d}_bold')

    # Functional (references)
    fmap = create_key('fmap/sub-{subject}_dir-{acq}_run-{item:02d}_epi')

    info = {t1:[], afford:[], rest:[], fmap:[]}

    for idx, s in enumerate(seqinfo):
        print('\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
        print(s)
        print(idx)
        # Anatomicals
        if ('MPRAGE' in s.protocol_name):
            info[t1] = [s.series_id]
        # Functionals (resting state and video experiment)
        if (s.dim4 == 244) and ('bic_epi_v1' in s.protocol_name):
            info[afford].append({'item': s.series_id})
        if (s.dim4 == 200) and ('bic_epi_v1_rest_state' in s.protocol_name) :
            info[rest].append({'item': s.series_id})
        # fmap
        if (s.dim4 == 10) and ('bic_epi_v1_swap_phaseenc' in s.protocol_name):
            info[fmap].append({'item': s.series_id, 'acq': 'PA'})
    print(info)
    return info
